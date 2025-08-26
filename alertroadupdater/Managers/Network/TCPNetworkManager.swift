import Foundation

/// Clase encargada de gestionar la conexión TCP y el envío de archivos a un dispositivo remoto
/// siguiendo un protocolo personalizado basado en paquetes con CRC y confirmaciones.
/// Utiliza `SimpleSocket` para la comunicación de bajo nivel.
class TCPNetworkManager {
    var onProgress: ((Int) -> Void)?
    var onComplete: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let TIMEOUT: TimeInterval = 5
    private let DATA_LEN = 1024
    private let HEADER_LEN = 3
    private let CRC_LEN = 2
    private let MAX_RETRIES = 5
    
    func connectAndSendFile(fileURL: URL, to ip: String, port: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var fileData = try Data(contentsOf: fileURL)
                let fileSize = fileData.count
                var blockNumber: UInt8 = 0
                var totalSent = 0
                
                let socket = try self.createSocket(ip: ip, port: port)
                defer {
                    socket.close()
                }
                
                try self.sendReadyMessage(socket: socket)
                guard try self.awaitAck(socket: socket) else {
                    self.onError?("No se recibió confirmación tras 'ready'")
                    return
                }
                
                Thread.sleep(forTimeInterval: 3.0)
                
                try self.sendUpgradeCommand(socket: socket)
                guard try self.awaitAck(socket: socket) else {
                    self.onError?("No se recibió confirmación tras 'upgrade'")
                    return
                }
                
                while totalSent < fileSize {
                    var block = fileData.prefix(self.DATA_LEN)
                    if block.count < self.DATA_LEN {
                        block += Data(repeating: 0, count: self.DATA_LEN - block.count)
                    }
                    
                    let packet = self.preparePacket(data: block, blockNumber: blockNumber)
                    try socket.write(packet)
                    
                    totalSent += block.count
                    let percent = Int(Double(totalSent) / Double(fileSize) * 100)
                    DispatchQueue.main.async {
                        self.onProgress?(min(percent, 100))
                    }
                    
                    guard try self.awaitBlockAck(socket: socket, expectedBlockNumber: blockNumber) else {
                        self.onError?("Error al enviar bloque \(blockNumber)")
                        return
                    }
                    
                    fileData = fileData.dropFirst(self.DATA_LEN)
                    blockNumber = blockNumber &+ 1
                }
                
                DispatchQueue.main.async {
                    self.onComplete?()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.onError?("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func createSocket(ip: String, port: Int) throws -> SimpleSocket {
        let socket = SimpleSocket()
        try socket.connect(host: ip, port: port, timeout: TIMEOUT)
        return socket
    }
    
    private func sendReadyMessage(socket: SimpleSocket) throws {
        try socket.write("ready\n".data(using: .utf8)!)
    }
    
    private func sendUpgradeCommand(socket: SimpleSocket) throws {
        try socket.write("upgrade\r".data(using: .utf8)!)
    }
    
    private func awaitAck(socket: SimpleSocket) throws -> Bool {
        let response = try socket.read(length: 10)
        return response.first == UInt8(ascii: "C")
    }
    
    private func awaitBlockAck(socket: SimpleSocket, expectedBlockNumber: UInt8) throws -> Bool {
        for _ in 0..<MAX_RETRIES {
            let response = try socket.read(length: 10)
            guard let firstByte = response.first else { continue }
            
            if [UInt8(ascii: "C"), UInt8(ascii: "Q"), 0].contains(firstByte) {
                return true
            } else if firstByte == UInt8(ascii: "R") {
                return false
            }
            
            Thread.sleep(forTimeInterval: 1)
        }
        return false
    }
    
    private func preparePacket(data: Data, blockNumber: UInt8) -> Data {
        var packet = Data()
        packet.append(0x01)
        packet.append(blockNumber)
        packet.append(~blockNumber)
        packet.append(data)
        
        let crc = generateCRC(data: data)
        packet.append(crc.0)
        packet.append(crc.1)
        return packet
    }
    
    private func generateCRC(data: Data) -> (UInt8, UInt8) {
        var crc = UInt16(0)
        let polynomial: UInt16 = 0x1021
        
        for byte in data {
            var current = UInt16(byte) << 8
            for _ in 0..<8 {
                if ((crc ^ current) & 0x8000) != 0 {
                    crc = (crc << 1) ^ polynomial
                } else {
                    crc <<= 1
                }
                current <<= 1
            }
        }
        
        return (UInt8((crc >> 8) & 0xff), UInt8(crc & 0xff))
    }
}
