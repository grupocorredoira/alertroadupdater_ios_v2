import Foundation

/// Clase que gestiona una conexión TCP simple mediante `InputStream` y `OutputStream`.
/// Proporciona métodos para conectarse a un host, enviar y recibir datos, y cerrar la conexión.
/// Pensada para conexiones directas con dispositivos en red local.
class SimpleSocket {
    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    // 🆕 Timeout global para lectura y escritura (en segundos)
    var readWriteTimeout: TimeInterval = 15 // 🆕

    func connect(host: String, port: Int, timeout: TimeInterval) throws {
        print("🔌 [SimpleSocket] Intentando conectar con \(host):\(port)")

        var input: InputStream?
        var output: OutputStream?

        Stream.getStreamsToHost(withName: host, port: port, inputStream: &input, outputStream: &output)

        // ❌ Error -101: No se pudieron obtener los streams
        guard let inputStream = input, let outputStream = output else {
            let code = -101
            let description = "No se pudieron obtener los flujos de entrada/salida"
            let message = "Error \(code): " + "socket_error".localized
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        self.inputStream = inputStream
        self.outputStream = outputStream

        inputStream.schedule(in: .current, forMode: .default)
        outputStream.schedule(in: .current, forMode: .default)

        inputStream.open()
        outputStream.open()

        // ❌ Error -102: Timeout al abrir los streams
        let startTime = Date()
        while inputStream.streamStatus != .open || outputStream.streamStatus != .open {
            if Date().timeIntervalSince(startTime) > timeout {
                let code = -102
                let description = "Timeout al abrir los flujos de datos"
                let message = "Error \(code): " + "socket_error".localized
                print("❌ [SimpleSocket] \(description)")
                throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }

        print("✅ [SimpleSocket] Streams abiertos correctamente")
    }

    func write(_ data: Data) throws {
        // ❌ Error -103: OutputStream no disponible
        guard let outputStream = outputStream else {
            let code = -103
            let description = "OutputStream no disponible"
            let message = "Error \(code): " + "socket_error".localized
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        let startTime = Date() // 🆕
        var totalBytesWritten = 0 // 🆕

        while totalBytesWritten < data.count && Date().timeIntervalSince(startTime) < readWriteTimeout { // 🆕
            if outputStream.hasSpaceAvailable {
                let remainingData = data.subdata(in: totalBytesWritten..<data.count) // 🆕
                let bytesWritten = remainingData.withUnsafeBytes {
                    outputStream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: remainingData.count)
                }

                if bytesWritten <= 0 {
                    let code = -104
                    let description = "No se pudieron escribir los datos"
                    let message = "Error \(code): " + "socket_error".localized
                    print("❌ [SimpleSocket] \(description)")
                    throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
                }

                totalBytesWritten += bytesWritten // 🆕
            }

            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05)) // 🆕
        }

        if totalBytesWritten < data.count { // 🆕
            let code = -108
            let description = "Timeout al escribir datos en el socket"
            let message = "Error \(code): " + "socket_error".localized
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        print("📤 [SimpleSocket] Escribió \(totalBytesWritten) bytes")
    }

    func read(length: Int) throws -> Data {
        // ❌ Error -105: InputStream no disponible
        guard let inputStream = inputStream else {
            let code = -105
            let description = "InputStream no disponible"
            let message = "Error \(code): " + "socket_error".localized
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        var buffer = [UInt8](repeating: 0, count: length)
        let startTime = Date() // 🆕
        var bytesRead = 0 // 🆕

        while bytesRead == 0 && Date().timeIntervalSince(startTime) < readWriteTimeout { // 🆕
            if inputStream.hasBytesAvailable {
                bytesRead = inputStream.read(&buffer, maxLength: length)
                break
            }

            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05)) // 🆕
        }

        // ❌ Error -106: Error al leer del socket
        // ❌ Error -107: Error timeout, puede que tenga que repetir varias veces el intento
        if bytesRead < 0 {
            let code = -106
            let description = "Error al leer del socket"
            let message = "Error \(code): " + "socket_error".localized
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        if bytesRead == 0 { // 🆕
            let code = -107
            let description = "Timeout al leer datos del socket"
            let message = "Error \(code): " + "socket_error_timeout".localized
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        print("📥 [SimpleSocket] Leyó \(bytesRead) bytes")
        return Data(buffer.prefix(bytesRead))
    }

    func close() {
        print("🔒 [SimpleSocket] Cerrando streams")
        inputStream?.close()
        outputStream?.close()
    }
}
