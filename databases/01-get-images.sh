#!/bin/bash

# source: http://bias.csr.unibo.it/fvc2004/download.asp

# baixar arquivos
for i in `seq 1 4`
do
  wget "http://bias.csr.unibo.it/fvc2004/Downloads/DB${i}_B.zip"
done

# excluir diretórios
rm -rf db?

# extrair arquivos
for i in `seq 1 4`
do
  mkdir db$i
  unzip zips/DB${i}_B.zip -d db$i/
done

exit 0

