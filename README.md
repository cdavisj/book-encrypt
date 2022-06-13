# book-encrypt
This program encrypts and decrypts files using a variant of book encrypt. It is written and tested in both C and ARMV6 assembly.

## Usage
**Arm version**:
```
./encrypter (-d|-e) -b <bookfile> <encryption_file>
```

**C version**:
```
./Cencrypter (-d|-e) -b <bookfile> <encryption_file>
```

| Flag | Description |
| :---: | :--- |
| -d | Sets the program to decrypt mode. |
| -e   | Sets the program to encrypt mode. |
| -b \<bookfile\>   | Path to input book file. This is the file that will be used for the encryption and/or decryption. |
| \<encryption_file\> | When **encrypting**, this is the path to the **output** file, overwriting whatever exists. The input file to be encrypted is read from stdin. When **decrypting**, this is the path to the **input** file, containing a previously book encrypted file. The decrypted file is written to stdout. |
