require "reversible_cryptography"

module Whaletamer
  class Compiler
    class Encrypter
      def decrypt_object(o)
        case o
        when Array
          o.map{|e| decrypt_object(e) }
        when Hash
          if o.keys == ["_encrypted"]
            decrypt(o["_encrypted"])
          else
            o.each_with_object({}) do |(k, v), h|
              h[k] = decrypt_object(v)
            end
          end
        else
          o
        end
      end

      def decrypt(encrypted)
        ReversibleCryptography::Message.decrypt(encrypted, encryption_key)
      end

      def encrypt(plain)
        ReversibleCryptography::Message.encrypt(plain, encryption_key)
      end

      def encryption_key
        @encryption_key = ENV["ENCRYPTION_KEY"] || File.read("encryption_key")
      end
    end
  end
end
