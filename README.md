# book-encrypt
This program encrypts and decrypts files using a variant of book encrypt. It is written and tested in both C and ARMV6 assembly.

## Usage
**Arm version: ./encrypter (-d|-e) -b \<bookfile\> \<encryption_file\>**
**C version: ./Cencrypter (-d|-e) -b \<bookfile\> \<encryption_file\>**
| Flag | Description |
| ----------- | ----------- |
| -d | Sets the program to decrypt mode. **Exactly 1 of -d OR -e must be provided, but not both** |
| -e   | Sets the program to decrypt mode. **Exactly 1 of -d OR -e must be provided, but not both** |
| -b \<bookfile\>   | Path to input book file. |
| encryption_file | When **encrypting**, this is the path to the **output** file, overwriting whatever exists. The input file to be encrypted is read from stdin. When **decrypting**, this is the path to the **input** file, containing a previously book encrypted file. The decrypted file is written to stdout. |
