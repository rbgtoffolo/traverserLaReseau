@echo off
set SCLANG_PATH="C:\Program Files\SuperCollider-3.13.0\sclang.exe"
:: Tenta rodar o sclang com o script instalador
%SCLANG_PATH% "%~dp0installer.scd"
pause