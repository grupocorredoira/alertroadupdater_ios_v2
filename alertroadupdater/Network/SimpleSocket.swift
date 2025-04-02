import Foundation

class SimpleSocket {
    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    func connect(host: String, port: Int, timeout: TimeInterval) throws {
        print("🔌 [SimpleSocket] Intentando conectar con \(host):\(port)")

        var input: InputStream?
        var output: OutputStream?

        Stream.getStreamsToHost(withName: host, port: port, inputStream: &input, outputStream: &output)

        // ❌ Error -101: No se pudieron obtener los streams
        guard let inputStream = input, let outputStream = output else {
            let code = -101
            let description = "No se pudieron obtener los flujos de entrada/salida"
            let message = "Error [\(code)]: Prueba a cerrar y a abrir la aplicación e intentarlo más tarde."
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
                let message = "Error [\(code)]: Prueba a cerrar y a abrir la aplicación e intentarlo más tarde."
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
            let message = "Error [\(code)]: Prueba a cerrar y a abrir la aplicación e intentarlo más tarde."
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        let bytesWritten = data.withUnsafeBytes {
            outputStream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
        }

        // ❌ Error -104: No se pudieron escribir los datos
        if bytesWritten <= 0 {
            let code = -104
            let description = "No se pudieron escribir los datos"
            let message = "Error [\(code)]: Prueba a cerrar y a abrir la aplicación e intentarlo más tarde."
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        print("📤 [SimpleSocket] Escribió \(bytesWritten) bytes")
    }

    func read(length: Int) throws -> Data {
        // ❌ Error -105: InputStream no disponible
        guard let inputStream = inputStream else {
            let code = -105
            let description = "InputStream no disponible"
            let message = "Error [\(code)]: Prueba a cerrar y a abrir la aplicación e intentarlo más tarde."
            print("❌ [SimpleSocket] \(description)")
            throw NSError(domain: "SimpleSocket", code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }

        var buffer = [UInt8](repeating: 0, count: length)
        let bytesRead = inputStream.read(&buffer, maxLength: length)

        // ❌ Error -106: Error al leer del socket
        if bytesRead < 0 {
            let code = -106
            let description = "Error al leer del socket"
            let message = "Error [\(code)]: Prueba a cerrar y a abrir la aplicación e intentarlo más tarde."
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





/*import Foundation

class SimpleSocket {
    private var inputStream: InputStream?
    private var outputStream: OutputStream?

    func connect(host: String, port: Int, timeout: TimeInterval) throws {
        print("🔌 [SimpleSocket] Intentando conectar con \(host):\(port)")
        var input: InputStream?
        var output: OutputStream?

        Stream.getStreamsToHost(withName: host, port: port, inputStream: &input, outputStream: &output)

        // TODO - verificar
        guard let inputStream = input, let outputStream = output else {
            print("❌ [SimpleSocket] No se pudieron obtener los streams")
            throw NSError(domain: "SimpleSocket", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudieron obtener los streams"])
        }

        self.inputStream = inputStream
        self.outputStream = outputStream

        inputStream.schedule(in: .current, forMode: .default)
        outputStream.schedule(in: .current, forMode: .default)

        inputStream.open()
        outputStream.open()

        // TODO - verificar
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
            print("❌ [SimpleSocket] OutputStream no disponible")
            throw NSError(domain: "SimpleSocket", code: -3, userInfo: [NSLocalizedDescriptionKey: "OutputStream no disponible"])
        }

        let bytesWritten = data.withUnsafeBytes {
            outputStream.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: data.count)
        }

        if bytesWritten <= 0 {
            print("❌ [SimpleSocket] Fallo al escribir datos")
            throw NSError(domain: "SimpleSocket", code: -4, userInfo: [NSLocalizedDescriptionKey: "No se pudieron escribir los datos"])
        }

        print("📤 [SimpleSocket] Escribió \(bytesWritten) bytes")
    }

    func read(length: Int) throws -> Data {
        guard let inputStream = inputStream else {
            print("❌ [SimpleSocket] InputStream no disponible")
            throw NSError(domain: "SimpleSocket", code: -5, userInfo: [NSLocalizedDescriptionKey: "InputStream no disponible"])
        }

        var buffer = [UInt8](repeating: 0, count: length)
        let bytesRead = inputStream.read(&buffer, maxLength: length)

        if bytesRead < 0 {
            print("❌ [SimpleSocket] Error al leer del socket")
            throw NSError(domain: "SimpleSocket", code: -6, userInfo: [NSLocalizedDescriptionKey: "Error al leer del socket"])
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
*/
