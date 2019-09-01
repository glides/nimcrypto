import nimcrypto/blowfish, nimcrypto/utils
import unittest

## Tests made according to official test vectors by Eric Young
## [https://www.schneier.com/code/vectors.txt] and adopted version by
## Randy L. Milbert [https://www.schneier.com/code/vectors2.txt], except
## chaining mode tests.

suite "Blowfish Tests":

  const
    NUM_VARIABLE_KEY_TESTS = 34
    NUM_SET_KEY_TESTS = 24

    # plaintext bytes -- left halves
    plaintext_l = [
      0x00000000'u32, 0xFFFFFFFF'u32, 0x10000000'u32, 0x11111111'u32,
      0x11111111'u32, 0x01234567'u32, 0x00000000'u32, 0x01234567'u32,
      0x01A1D6D0'u32, 0x5CD54CA8'u32, 0x0248D438'u32, 0x51454B58'u32,
      0x42FD4430'u32, 0x059B5E08'u32, 0x0756D8E0'u32, 0x762514B8'u32,
      0x3BDD1190'u32, 0x26955F68'u32, 0x164D5E40'u32, 0x6B056E18'u32,
      0x004BD6EF'u32, 0x480D3900'u32, 0x437540C8'u32, 0x072D43A0'u32,
      0x02FE5577'u32, 0x1D9D5C50'u32, 0x30553228'u32, 0x01234567'u32,
      0x01234567'u32, 0x01234567'u32, 0xFFFFFFFF'u32, 0x00000000'u32,
      0x00000000'u32, 0xFFFFFFFF'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32,
      0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32,
      0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32,
      0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32,
      0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32,
      0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32, 0xFEDCBA98'u32,
      0xFEDCBA98'u32, 0xFEDCBA98'u32
    ]

    # plaintext bytes -- right halves
    plaintext_r = [
      0x00000000'u32, 0xFFFFFFFF'u32, 0x00000001'u32, 0x11111111'u32,
      0x11111111'u32, 0x89ABCDEF'u32, 0x00000000'u32, 0x89ABCDEF'u32,
      0x39776742'u32, 0x3DEF57DA'u32, 0x06F67172'u32, 0x2DDF440A'u32,
      0x59577FA2'u32, 0x51CF143A'u32, 0x774761D2'u32, 0x29BF486A'u32,
      0x49372802'u32, 0x35AF609A'u32, 0x4F275232'u32, 0x759F5CCA'u32,
      0x09176062'u32, 0x6EE762F2'u32, 0x698F3CFA'u32, 0x77075292'u32,
      0x8117F12A'u32, 0x18F728C2'u32, 0x6D6F295A'u32, 0x89ABCDEF'u32,
      0x89ABCDEF'u32, 0x89ABCDEF'u32, 0xFFFFFFFF'u32, 0x00000000'u32,
      0x00000000'u32, 0xFFFFFFFF'u32, 0x76543210'u32, 0x76543210'u32,
      0x76543210'u32, 0x76543210'u32, 0x76543210'u32, 0x76543210'u32,
      0x76543210'u32, 0x76543210'u32, 0x76543210'u32, 0x76543210'u32,
      0x76543210'u32, 0x76543210'u32, 0x76543210'u32, 0x76543210'u32,
      0x76543210'u32, 0x76543210'u32, 0x76543210'u32, 0x76543210'u32,
      0x76543210'u32, 0x76543210'u32, 0x76543210'u32, 0x76543210'u32,
      0x76543210'u32, 0x76543210'u32
    ]

    # key bytes for variable key tests
    variable_key = [
      [0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8],
      [0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8],
      [0x30'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8],
      [0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8],
      [0x01'u8, 0x23'u8, 0x45'u8, 0x67'u8, 0x89'u8, 0xAB'u8, 0xCD'u8, 0xEF'u8],
      [0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8, 0x11'u8],
      [0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8],
      [0xFE'u8, 0xDC'u8, 0xBA'u8, 0x98'u8, 0x76'u8, 0x54'u8, 0x32'u8, 0x10'u8],
      [0x7C'u8, 0xA1'u8, 0x10'u8, 0x45'u8, 0x4A'u8, 0x1A'u8, 0x6E'u8, 0x57'u8],
      [0x01'u8, 0x31'u8, 0xD9'u8, 0x61'u8, 0x9D'u8, 0xC1'u8, 0x37'u8, 0x6E'u8],
      [0x07'u8, 0xA1'u8, 0x13'u8, 0x3E'u8, 0x4A'u8, 0x0B'u8, 0x26'u8, 0x86'u8],
      [0x38'u8, 0x49'u8, 0x67'u8, 0x4C'u8, 0x26'u8, 0x02'u8, 0x31'u8, 0x9E'u8],
      [0x04'u8, 0xB9'u8, 0x15'u8, 0xBA'u8, 0x43'u8, 0xFE'u8, 0xB5'u8, 0xB6'u8],
      [0x01'u8, 0x13'u8, 0xB9'u8, 0x70'u8, 0xFD'u8, 0x34'u8, 0xF2'u8, 0xCE'u8],
      [0x01'u8, 0x70'u8, 0xF1'u8, 0x75'u8, 0x46'u8, 0x8F'u8, 0xB5'u8, 0xE6'u8],
      [0x43'u8, 0x29'u8, 0x7F'u8, 0xAD'u8, 0x38'u8, 0xE3'u8, 0x73'u8, 0xFE'u8],
      [0x07'u8, 0xA7'u8, 0x13'u8, 0x70'u8, 0x45'u8, 0xDA'u8, 0x2A'u8, 0x16'u8],
      [0x04'u8, 0x68'u8, 0x91'u8, 0x04'u8, 0xC2'u8, 0xFD'u8, 0x3B'u8, 0x2F'u8],
      [0x37'u8, 0xD0'u8, 0x6B'u8, 0xB5'u8, 0x16'u8, 0xCB'u8, 0x75'u8, 0x46'u8],
      [0x1F'u8, 0x08'u8, 0x26'u8, 0x0D'u8, 0x1A'u8, 0xC2'u8, 0x46'u8, 0x5E'u8],
      [0x58'u8, 0x40'u8, 0x23'u8, 0x64'u8, 0x1A'u8, 0xBA'u8, 0x61'u8, 0x76'u8],
      [0x02'u8, 0x58'u8, 0x16'u8, 0x16'u8, 0x46'u8, 0x29'u8, 0xB0'u8, 0x07'u8],
      [0x49'u8, 0x79'u8, 0x3E'u8, 0xBC'u8, 0x79'u8, 0xB3'u8, 0x25'u8, 0x8F'u8],
      [0x4F'u8, 0xB0'u8, 0x5E'u8, 0x15'u8, 0x15'u8, 0xAB'u8, 0x73'u8, 0xA7'u8],
      [0x49'u8, 0xE9'u8, 0x5D'u8, 0x6D'u8, 0x4C'u8, 0xA2'u8, 0x29'u8, 0xBF'u8],
      [0x01'u8, 0x83'u8, 0x10'u8, 0xDC'u8, 0x40'u8, 0x9B'u8, 0x26'u8, 0xD6'u8],
      [0x1C'u8, 0x58'u8, 0x7F'u8, 0x1C'u8, 0x13'u8, 0x92'u8, 0x4F'u8, 0xEF'u8],
      [0x01'u8, 0x01'u8, 0x01'u8, 0x01'u8, 0x01'u8, 0x01'u8, 0x01'u8, 0x01'u8],
      [0x1F'u8, 0x1F'u8, 0x1F'u8, 0x1F'u8, 0x0E'u8, 0x0E'u8, 0x0E'u8, 0x0E'u8],
      [0xE0'u8, 0xFE'u8, 0xE0'u8, 0xFE'u8, 0xF1'u8, 0xFE'u8, 0xF1'u8, 0xFE'u8],
      [0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8, 0x00'u8],
      [0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8, 0xFF'u8],
      [0x01'u8, 0x23'u8, 0x45'u8, 0x67'u8, 0x89'u8, 0xAB'u8, 0xCD'u8, 0xEF'u8],
      [0xFE'u8, 0xDC'u8, 0xBA'u8, 0x98'u8, 0x76'u8, 0x54'u8, 0x32'u8, 0x10'u8]]

    # key bytes for set key tests
    set_key = [
      0xF0'u8, 0xE1'u8, 0xD2'u8, 0xC3'u8, 0xB4'u8, 0xA5'u8, 0x96'u8, 0x87'u8,
      0x78'u8, 0x69'u8, 0x5A'u8, 0x4B'u8, 0x3C'u8, 0x2D'u8, 0x1E'u8, 0x0F'u8,
      0x00'u8, 0x11'u8, 0x22'u8, 0x33'u8, 0x44'u8, 0x55'u8, 0x66'u8, 0x77'u8
    ]

    # ciphertext bytes -- left halves
    ciphertext_l = [
      0x4EF99745'u32, 0x51866FD5'u32, 0x7D856F9A'u32, 0x2466DD87'u32,
      0x61F9C380'u32, 0x7D0CC630'u32, 0x4EF99745'u32, 0x0ACEAB0F'u32,
      0x59C68245'u32, 0xB1B8CC0B'u32, 0x1730E577'u32, 0xA25E7856'u32,
      0x353882B1'u32, 0x48F4D088'u32, 0x432193B7'u32, 0x13F04154'u32,
      0x2EEDDA93'u32, 0xD887E039'u32, 0x5F99D04F'u32, 0x4A057A3B'u32,
      0x452031C1'u32, 0x7555AE39'u32, 0x53C55F9C'u32, 0x7A8E7BFA'u32,
      0xCF9C5D7A'u32, 0xD1ABB290'u32, 0x55CB3774'u32, 0xFA34EC48'u32,
      0xA7907951'u32, 0xC39E072D'u32, 0x014933E0'u32, 0xF21E9A77'u32,
      0x24594688'u32, 0x6B5C5A9C'u32, 0xF9AD597C'u32, 0xE91D21C1'u32,
      0xE9C2B70A'u32, 0xBE1E6394'u32, 0xB39E4448'u32, 0x9457AA83'u32,
      0x8BB77032'u32, 0xE87A244E'u32, 0x15750E7A'u32, 0x122BA70B'u32,
      0x3A833C9A'u32, 0x9409DA87'u32, 0x884F8062'u32, 0x1F85031C'u32,
      0x79D9373A'u32, 0x93142887'u32, 0x03429E83'u32, 0xA4299E27'u32,
      0xAFD5AED1'u32, 0x10851C0E'u32, 0xE6F51ED7'u32, 0x64A6E14A'u32,
      0x80C7D7D4'u32, 0x05044B62'u32
    ]

    # ciphertext bytes -- right halves
    ciphertext_r = [
      0x6198DD78'u32, 0xB85ECB8A'u32, 0x613063F2'u32, 0x8B963C9D'u32,
      0x2281B096'u32, 0xAFDA1EC7'u32, 0x6198DD78'u32, 0xC6A0A28D'u32,
      0xEB05282B'u32, 0x250F09A0'u32, 0x8BEA1DA4'u32, 0xCF2651EB'u32,
      0x09CE8F1A'u32, 0x4C379918'u32, 0x8951FC98'u32, 0xD69D1AE5'u32,
      0xFFD39C79'u32, 0x3C2DA6E3'u32, 0x5B163969'u32, 0x24D3977B'u32,
      0xE4FADA8E'u32, 0xF59B87BD'u32, 0xB49FC019'u32, 0x937E89A3'u32,
      0x4986ADB5'u32, 0x658BC778'u32, 0xD13EF201'u32, 0x47B268B2'u32,
      0x08EA3CAE'u32, 0x9FAC631D'u32, 0xCDAFF6E4'u32, 0xB71C49BC'u32,
      0x5754369A'u32, 0x5D9E0A5A'u32, 0x49DB005E'u32, 0xD961A6D6'u32,
      0x1BC65CF3'u32, 0x08640F05'u32, 0x1BDB1E6E'u32, 0xB1928C0D'u32,
      0xF960629D'u32, 0x2CC85E82'u32, 0x4F4EC577'u32, 0x3AB64AE0'u32,
      0xFFC537F6'u32, 0xA90F6BF2'u32, 0x5060B8B4'u32, 0x19E11968'u32,
      0x714CA34F'u32, 0xEE3BE15C'u32, 0x8CE2D14B'u32, 0x469FF67B'u32,
      0xC1BC96A8'u32, 0x3858DA9F'u32, 0x9B9DB21F'u32, 0xFD36B46F'u32,
      0x5A5479AD'u32, 0xFA52D080'u32
    ]

  var ctx: blowfish

  test "Encryption test #1":
    for i in 0..<NUM_VARIABLE_KEY_TESTS:
      var key = variable_key[i]
      ctx.init(addr key[0], len(key))
      var data = [plaintext_l[i], plaintext_r[i]]
      ctx.encrypt(cast[ptr uint8](addr data[0]), cast[ptr uint8](addr data[0]))
      ctx.clear()
      check:
        ciphertext_l[i] == data[0]
        ciphertext_r[i] == data[1]
        ctx.isFullZero() == true

  test "Decryption test #1":
    for i in 0..<NUM_VARIABLE_KEY_TESTS:
      var key = variable_key[i]
      ctx.init(addr key[0], len(key))
      var data = [ciphertext_l[i], ciphertext_r[i]]
      ctx.decrypt(cast[ptr uint8](addr data[0]), cast[ptr uint8](addr data[0]))
      ctx.clear()
      check:
        plaintext_l[i] == data[0]
        plaintext_r[i] == data[1]
        ctx.isFullZero() == true

  test "Encryption test #2":
    for i in 0..<NUM_SET_KEY_TESTS:
      var key = set_key[0..i]
      ctx.init(addr key[0], len(key))
      var data = [plaintext_l[NUM_VARIABLE_KEY_TESTS + i],
                  plaintext_r[NUM_VARIABLE_KEY_TESTS + i]]
      ctx.encrypt(cast[ptr uint8](addr data[0]), cast[ptr uint8](addr data[0]))
      ctx.clear()
      check:
        ciphertext_l[NUM_VARIABLE_KEY_TESTS + i] == data[0]
        ciphertext_r[NUM_VARIABLE_KEY_TESTS + i] == data[1]
        ctx.isFullZero() == true

  test "Decryption test #2":
    for i in 0..<NUM_SET_KEY_TESTS:
      var key = set_key[0..i]
      ctx.init(addr key[0], len(key))
      var data = [ciphertext_l[NUM_VARIABLE_KEY_TESTS + i],
                  ciphertext_r[NUM_VARIABLE_KEY_TESTS + i]]
      ctx.decrypt(cast[ptr uint8](addr data[0]), cast[ptr uint8](addr data[0]))
      ctx.clear()
      check:
        plaintext_l[NUM_VARIABLE_KEY_TESTS + i] == data[0]
        plaintext_r[NUM_VARIABLE_KEY_TESTS + i] == data[1]
        ctx.isFullZero() == true
