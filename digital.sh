#!/usr/bin/env bash

rm -f digital.v
cp PoliLobinho.v digital
echo >> digital
mv PoliLobinho.v PoliLobinho
for f in *.v; do (cat "${f}"; echo) >> digital; done
mv PoliLobinho PoliLobinho.v
mv digital digital.v