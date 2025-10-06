# Kuvaus
Qt-Creator kehitysympäristöä käyttäen luotu tehtävienhallintasovellus Androidille, joka auttaa käyttäjää hallitsemaan omia tehtäviään yksinkertaisella ja selkeällä käyttöliittymällä. 

Sovellus tehty kahden hengen tiimissä, jossa tiimijäsenistä yksi hoiti sovelluksen liiketoimintalogiikan, toinen graafisen suunnittelun.

Logiikka toteutettu Qt Creatorilla käyttäen C++-kieltä. Graafiseen käyttöliittymäsuunnitteluun on käytetty Qt Design Studiota.

# Keskeiset toiminnot
Lisää uusia tehtäviä

Näyttää kaikki tehtävät listassa

Merkitse tehtävä tehdyksi (päivämäärä ja kellonaika näkyvissä)

Muokkaa tehtävän tietoja (otsikko, kuvaus, väri)

Poista tehtäviä

Säilyttää tehtävät sovelluksen uudelleenkäynnistyksen jälkeen

Priorisoi tehtäviä kiireellisyystunnuksilla

Tumma/vaalea teema

Aseta eräpäivä tehtäville

Jaa tehtäviä muille sovellusten kautta (Share Sheet)

# Asennus ja käyttö
## Kehitysympäristön tasolla
Asenna Qt Creator sekä tarvittavat Android SDK ja NDK -työkalut.

Varmista, että laitteellasi on asennettuna Java Development Kit (JDK).

Kytke Android-laite USB-kaapelilla tietokoneeseen ja salli USB-debuggaus.

Lisää Main.qml ja main.cpp koodipätkät oikeisiin paikkoihin

Buildaa sovellus Qt Creatorissa ja asenna APK Android-laitteelle.

## Muuten
Lataa Githubista .apk päätteinen tiedosto, ja siirrä Android laitteellesi

Suorita tiedosto, ja seuraa ohjeita

# Testaus
Sovellus testattu Android 15 -laitteella
Testitapaukset kattavat sovelluksen perus- ja lisäominaisuudet:

Uuden tehtävän lisääminen	
Käyttäjä voi lisätä uuden tehtävän	Tehtävä tallentuu ja näkyy listassa

Tehtävälistan näyttäminen	
Kaikki tallennetut tehtävät näkyvät	Näkyy selkeästi listassa

Tehtävän merkitseminen tehdyksi	
Päivämäärä ja kellonaika tallentuvat	Tehtävä tila = ‘Completed’

Tehtävän merkinnän peruuttaminen	
Peruuta merkintä	Tehtävä tila = ‘Pending’

Poistaminen listasta	
Tehtävä poistuu pysyvästi

Tehtävien jakaminen	
Share Sheet -toiminto	Tehtävät jaetaan oikein

Tehtävien priorisointi	
Kiireellisyysmerkinnät	Näkyy listassa oikeassa järjestyksessä

Teeman vaihto	Tumma/vaalea	
Teema vaihtuu onnistuneesti

Eräpäivän asettaminen	
Määritä eräpäivä, näkyy listassa ja tukee priorisointia

Tehtävän muokkaaminen	
Muokkaa otsikkoa/kuvausta. Muutokset tallentuvat oikein

Tehtävien säilyminen	
Sovelluksen uudelleenkäynnistys	Tehtävät säilyvät muistissa

# Jatkokäyttö ja kehitysmahdollisuudet
Push-ilmoitukset lähestyvistä eräpäivistä

Sovelluksen julkaisu Google Play ja iOS App Storeen

# Loppusanat
Projektin lopputulos on toimiva ja selkeä mobiilisovellus, joka helpottaa arjen ajanhallintaa. Kehitystyön aikana opittiin Qt Creatorin käyttö, C++-ohjelmointi, mobiilisovelluskehityksen perusteet sekä versionhallinta GitHubin avulla. Sovellus toimii pohjana jatkokehitykselle ja tarjoaa laajan mahdollisuuden uusien ominaisuuksien lisäämiselle.

# Lisenssi
Projekti on lisensoitu MIT License -lisenssillä. MIT-lisenssi on avoin ja sallii projektin käytön, kopioinnin, muokkaamisen ja jakamisen, kunhan alkuperäinen tekijä/tekijät mainitaan ja lisenssi liitetään mukaan.
