# Punycode
Swift 4 implementation of Punycode with IDNA encoding. API implemented as extensions for String and Substring types.

Usage:

    "погода-в-египте.рф".idnaEncoded()      // returns "xn-----6kcjcecmb3a1dbkl9b.xn--p1ai"
    "xn--viva-espaa-19a.com".idnaDecoded()  // returns "viva-españa.com"

You can also use Punycode directly to encode / decode any unicode string:

    "e77hd".PunycodeDecoded()               // returns Canadian flag emoji
