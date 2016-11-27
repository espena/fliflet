#!/bin/bash
useradd -U espena
echo "Kopierer grafikkfiler"
cp -vf ./gfx/* /root/oep-rapport/grafikk/.
chmod 664 /root/oep-rapport/grafikk/*
chown espena:espena /root/oep-rapport/grafikk/*
echo "Oppdaterer. oversiktstabell.tex"
./fiflet latex overview-table > /root/oep-rapport/oversiktstabell.tex
chmod 664 /root/oep-rapport/oversiktstabell.tex
chown espena:espena /root/oep-rapport/oversiktstabell.tex
echo "Oppdaterer: enkelteksempler.departementsliste.tex"
./fiflet latex appendix-examples > /root/oep-rapport/enkelteksempler.departementsliste.tex
chmod 664 /root/oep-rapport/enkelteksempler.departementsliste.tex
chown espena:espena /root/oep-rapport/enkelteksempler.departementsliste.tex
echo "Oppdaterer: tabeller_og_figurer.departementsliste.tex"
./fiflet latex appendix > /root/oep-rapport/tabeller_og_figurer.departementsliste.tex
chmod 664 /root/oep-rapport/tabeller_og_figurer.departementsliste.tex
chown espena:espena /root/oep-rapport/tabeller_og_figurer.departementsliste.tex
deluser espena
