#!/bin/bash

# source: http://bias.csr.unibo.it/fvc2004/download.asp

# criar diretório para os ZIPs
if [ ! -d zips ]
then
  mkdir zips
fi

# baixar arquivos
for i in `seq 1 4`
do
  arq="DB${i}_B.zip"
  if [ ! -f zips/$arq ]
  then
    wget "http://bias.csr.unibo.it/fvc2004/Downloads/${arq}"
    mv $arq zips/
  fi
done

# excluir diretórios
rm -rf images/

# extrair arquivos
for i in `seq 1 4`
do
  mkdir images/db$i
  unzip zips/DB${i}_B.zip -d images/db$i/
done

exit 0

