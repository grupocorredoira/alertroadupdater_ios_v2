import Foundation

class SimpleSocket {
    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    func connect(host: String, port: Int, timeout: TimeInterval) throws {
        var input: InputStream?
        var output: OutputStream?

        Stream.getStreamsToHost(withName: host, port: port, inputStream: &input, outputStream: &output)

        guard let inputStream = input, let outputStream = output else {
            throw NSError(domain: "SimpleSocket", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudieron obtener los streams"])
        }

        self.inputStream = inputStream
        self.outputStream = outputStream

        inputStream.schedule(in: .current, forMode: .default)
        outputStream.schedule(in: .current, forMode: .default)

        inputStream.open()
        outputStream.open()

        let startTime = Date()
        while inputStream.streamStatus != .open || outputStream.streamStatus != .open {
            if Date().timeIntervalSince(startTime) > timeout {
                throw NSError(domain: "SimpleSocket", code: -2, userInfo: [NSLocalizedDescriptionKey: "Timeout al abrir los streams"])
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.1))
        }
    }

    func write(_ data: Data) throws {
        guard let outputStream = outputStream else {
            throw NSError(domain: "SimpleSocket", code: -3, userInfo: [NSLocalizedDescriptionKey: "OutputStream no disponible"])
        }

        let bytesWritten = data.withUnsafeBytes {
            outputStream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
        }

        if bytesWritten <= 0 {
            throw NSError(domain: "SimpleSocket", code: -4, userInfo: [NSLocalizedDescriptionKey: "No se pudieron escribir los datos"])
        }
    }

    func read(length: Int) throws -> Data {
        guard let inputStream = inputStream else {
            throw NSError(domain: "SimpleSocket", code: -5, userInfo: [NSLocalizedDescriptionKey: "InputStream no disponible"])
        }

        var buffer = [UInt8](repeating: 0, count: length)
        let bytesRead = inputStream.read(&buffer, maxLength: length)

        if bytesRead < 0 {
            throw NSError(domain: "SimpleSocket", code: -6, userInfo: [NSLocalizedDescriptionKey: "Error al leer del socket"])
        }

        return Data(buffer.prefix(bytesRead))
    }

    func close() {
        inputStream?.close()
        outputStream?.close()
    }
}
