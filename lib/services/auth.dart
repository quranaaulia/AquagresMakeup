import 'dart:convert';
import 'package:crypto/crypto.dart';

String encryptPassword(String userPassword) {
  var bytes = utf8.encode(userPassword);
  var digest = sha256.convert(bytes);
  return digest.toString();
}