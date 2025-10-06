// Tallennusasetukset, mahdollistaa sovelluksen asetusten säilyttämisen
import Qt.labs.settings 1.1

// Peruskirjastot käyttöliittymän elementeille
import QtQuick 2.15

// Nykyaikaiset käyttöliittymäkontrollit (napit, tekstikentät jne.)
import QtQuick.Controls 2.15

// Layout-työkalut (ColumnLayout, RowLayout jne.)
import QtQuick.Layouts 1.15

// Sovellusikkunan hallintaan liittyvät ominaisuudet
import QtQuick.Window 2.15


// Sovelluksen pääikkuna
ApplicationWindow {

    // Ikkunan tunniste (id), jolla siihen voidaan viitata
    id: root

    // Asetetaan ikkuna näkyväksi
    visible: true

    // Ikkunan leveys: max 400px tai 90% näytön leveydestä
    width: Math.min(400, Screen.width * 0.9)

    // Ikkunan korkeus: max 700px tai 90% näytön korkeudesta
    height: Math.min(700, Screen.height * 0.9)

    // Ikkunan otsikko
    title: "Task Manager"

    // Pienin sallittu leveys
    minimumWidth: 300

    // Pienin sallittu korkeus
    minimumHeight: 500

    // Käytetäänkö tummaa teemaa (true/false)
    property bool darkTheme: true

    // Taustaväri teemasta riippuen
    property color backgroundColor: darkTheme ? "#2b2b2b" : "#f5f5f5"

    // Yläosan (header) väri
    property color headerColor: darkTheme ? "#747474" : "#e0e0e0"

    // Tekstien pääväri
    property color textColor: darkTheme ? "white" : "black"

    // Alapalkin (footer) väri
    property color footerColor: darkTheme ? "#1b1bb6" : "#3a5cde"

    // Dialogin taustaväri
    property color dialogColor: darkTheme ? "#3a3a3a" : "#e0e0e0"

    // Dialogin tekstiväri
    property color dialogTextColor: darkTheme ? "white" : "black"

    // Tehtävän oletustaustaväri
    property color taskColorDefault: "#3c3c3c"

    // Tehtävien tekstien väri
    property color taskTextColor:  "white"

    // Kuvaustekstin väri
    property color descriptionTextColor: "#fffaf0"

    // Settings-komponentti, jolla tallennetaan pysyviä asetuksia
    Settings {

        // Tunniste (id), jolla viitataan asetuksiin
        id: settings

        // Merkkijono, johon tallennetaan tehtävät
        property string tasks: "[]"

        // Tallennettu teeman tila (true = tumma, false = vaalea)
        property bool theme: true

        // Suoritetaan, kun komponentti on ladattu
        Component.onCompleted: {

            // Asetetaan pääikkunan tumma teema vastaamaan tallennettua arvoa
            darkTheme = theme
        }
    }

    // Funktio, joka tarkistaa, onko annettu päivämäärä menneisyydessä
    function isPastDate(dateString) {

        // Jos arvoa ei ole annettu, palautetaan false (Epätosi)
        if (!dateString) return false;

        // Jaetaan päivämäärä osiin pisteiden kohdalta (päivä.kuukausi.vuosi)
        var parts = dateString.split('.');

        if (parts.length !== 3) return false;

        // Päivä kokonaisluvuksi
        var day = parseInt(parts[0]);

        // Kuukausi kokonaisluvuksi
        var month = parseInt(parts[1]);

        // Vuosi kokonaisluvuksi
        var year = parseInt(parts[2]);

        // Luodaan Date-objekti, huomioi, että kuukaudet alkavat nollasta
        // Tammikuu = 0, Helmikuu = 1, Maaliskuu = 3, ja niin edelleen
        var selectedDate = new Date(year, month - 1, day);

        // Nykyinen päivämäärä
        var today = new Date();

        // Nollataan kellonaika (tällä tarkistetaan vain, mikä päivä tänään on)
        today.setHours(0, 0, 0, 0);

        // Palautetaan arvo true = Tosi, jos valittu päivämäärä on ennen tätä päivää
        return selectedDate < today;
    }

    // ListModel-komponentti, johon tehtävät tallennetaan muistissa
    ListModel {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: taskModel

        // Suoritetaan, kun komponentti on ladattu (luotu käyttöön)
        Component.onCompleted: {

            // Yritetään suorittaa tehtävien lataus
            try {

                // Ladataan teema-asetus pysyvistä asetuksista
                darkTheme = settings.theme

                // Haetaan tallennetut tehtävät pysyvistä asetuksista
                var savedTasks = JSON.parse(settings.tasks)

                // Käydään läpi jokainen tallennettu tehtävä
                for (var i = 0; i < savedTasks.length; i++) {

                    // Otetaan yksi tehtävä käsittelyyn
                    var task = savedTasks[i]

                    // Lisätään kyseinen tehtävä ListModel-komponenttiin
                    taskModel.append({

                        // Tehtävän nimi
                        "name": task.name,

                        // Tehtävän kuvaus, tai tyhjä, jos puuttuu
                        "description": task.description || "",

                        // Tehtävän eräpäivä tai tyhjä, jos puuttuu
                        "dueDate": task.dueDate || "",

                        // Onko tehtävä valmis, oletus = false
                        "completed": task.completed || false,

                        // Onko tehtävä kiireellinen, oletus = false
                        "urgent": task.urgent || false,

                        // Tehtävän väri, tai oletusväri
                        "taskColor": task.taskColor || taskColorDefault,

                        // Tehtävän luontiaika, tai tyhjä, jos puuttuu
                        "timestamp": task.timestamp || "",

                        // Tehtävän valmistumisaika tai tyhjä, jos puuttuu
                        "completionTime": task.completionTime || ""
                    })

                    // Jos tehtävä on merkitty tehdyksi
                    if (task.completed) {

                        // Lisätään laskuriin valmis tehtävä
                        completedCount++
                    }
                }

                // Lajitellaan tehtävät
                sortTasks()

            // Debuggausta varten:
            // Jos tehtävien latauksessa tapahtuu virhe
            } catch (e) {

                // Näytetään virheilmoitus konsoliin
                console.log("No saved tasks or error loading:", e)
            }
        }

        // Kun tehtävien määrä muuttuu, tallennetaan tehtävät
        onCountChanged: saveTasks()

        // Kun jonkin tehtävän tiedot puuttuvat, tallennetaan tehtävät
        onDataChanged: saveTasks()
    }

    // Ilmoitusponnahdus (Popup-komponentti, joka näyttää sovellussisäisiä ilmoituksia)
    Popup {

        // Ilmoituksen tunniste
        id: notification

        // Sijoitetaan keskelle vaakasuunnassa
        x: (parent.width - width) / 2

        // Pystysuunnassa 100 pikseliä ylhäältä
        y: 100

        // Leveys max 300 px tai 80% parentista
        width: Math.min(300, parent.width * 0.8)

        // Korkeus 80 pikseliä
        height: 80

        // Ei estä käyttöliittymän toimivuutta
        modal: false

        // Ei kohdista automaattisesti
        focus: false

        // Ilmoitus ei sulkeudu automaattisesti
        closePolicy: Popup.NoAutoClose

        // Ponnahdusilmoituksen tausta
        background: Rectangle {

            // Taustaväri otetaan teemasta
            color: dialogColor

            // Pyöristetyt kulmat
            radius: 10

            // Kehyksen väri
            border.color: textColor

            // Kehyksen paksuus
            border.width: 2
        }

        // Ilmoitussisältö sarakkeena
        contentItem: Column {

            // Keskitetään sisälle
            anchors.centerIn: parent

            // Väli elementtien välillä
            spacing: 5

            // Tekstielementti
            Text {

                // Näytetään huutomerkki
                text: "!"

                // Tekstin väri
                color: textColor

                // Lihavoitu fontti
                font.bold: true

                // Fontin koko 24 pikseliä
                font.pixelSize: 24

                // Keskitetään vaakasuuntaisesti
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Varsinainen ilmoitusteksti
            Text {

                // Tekstin tunniste
                id: notificationText

                // Aluksi tyhjä
                text: ""

                // Tekstin väri
                color: textColor

                // Fontin koko 14 pikseliä
                font.pixelSize: 14

                // Lihavoitu teksti
                font.bold: true

                // Keskitetään teksti vaakasuunnassa
                horizontalAlignment: Text.AlignHCenter

                // Teksti vie koko leveyden
                width: parent.width

                // Jos teksti on pitkä, se rivitetään
                wrapMode: Text.Wrap
            }
        }

        // Ajastin ilmoituksen sulkeutumiseen
        Timer {

            // Ajastimen tunniste
            id: notificationTimer

            // 2000 ms = 2 sekuntia
            interval: 2000

            // Suljetaan Popup, kun ajastimen aika on loppunut
            onTriggered: notification.close()
        }

        // Käynnistetään ajastin, kun Popup avataan
        onOpened: notificationTimer.start()
    }

    // Funktio ilmoituksen näyttämiseen
    function showNotification(message) {

        // Asetetaan viestiteksti
        notificationText.text = message

        // Avataan ponnahdusikkuna
        notification.open()

    }
    // Funktio tehtävien lajitteluun
    function sortTasks() {

        // Jos tehtäviä ei ole, lopetetaan
        if (taskModel.count === 0) return;

        // Luodaan tyhjä taulukko tehtäville
        var tasks = [];

        // Kerää kaikki tehtävät taulukkoon
        for (var i = 0; i < taskModel.count; i++) {

            // Haetaan taas yksi tehtävä TaskModel-komponentista
            var task = taskModel.get(i);

            // Lisätään taulukkoon:
            tasks.push({

                // Tehtävän nimi
                "name": task.name,

                // Tehtävän kuvaus tai tyhjä, jos puuttuu
                "description": task.description || "",

                // Tehtävän eräpäivä
                "dueDate": task.dueDate,

                // Onko tehtävä valmis
                "completed": task.completed,

                // Onko tehtävä kiireellinen
                "urgent": task.urgent,

                // Tehtävän väri
                "taskColor": task.taskColor,

                // Tehtävän luontiaika
                "timestamp": task.timestamp,

                // Tehtävän valmistumisaika
                "completionTime": task.completionTime
            });
        }

        // Tyhjennetään nykyinen komponentti
        taskModel.clear();

        // Lajittele tehtävät
        tasks.sort(function(a, b) {
            // Ensin valmiit, sitten odottavat
            if (a.completed && !b.completed) return 1;
            if (!a.completed && b.completed) return -1;

            // Sitten kiireelliset alkuun
            if (a.urgent && !b.urgent) return -1;
            if (!a.urgent && b.urgent) return 1;

            // Lopuksi aikajärjestyksen mukaan (timestamp)
            return new Date(a.timestamp) - new Date(b.timestamp);
        });

        // Lisätään järjestetyt tehtävät takaisin taskModel-komponenttiin
        for (var j = 0; j < tasks.length; j++) {
            taskModel.append(tasks[j]);
        }
    }

    // Laskuri, kuinka monta tehtävää on merkitty valmiiksi
    property int completedCount: 0

    // Funktio tehtävien tallentamiselle
    function saveTasks() {

        // Yritetään suorittaa tallennus
        try {

            // Luodaan taulukko tallennettaville tehtäville
            var tasks = []

            // Käydään läpi kaikki taskModel-komponentissa olevat tehtävät
            for (var i = 0; i < taskModel.count; i++) {

                // Haetaan yksi tehtävä komponentista
                var task = taskModel.get(i)

                // Lisätään tehtävä taulukkoon:
                tasks.push({

                    // Tehtävän nimi
                    "name": task.name,

                    // Tehtävän kuvaus tai tyhjä, jos puuttuu
                    "description": task.description || "",

                    // Tehtävän eräpäivä, tai tyhjä, jos puuttuu
                    "dueDate": task.dueDate || "",

                    // Onko tehtävä valmis
                    "completed": task.completed,

                    // Onko tehtävä kiireellinen
                    "urgent": task.urgent,

                    // Tehtävän väri
                    "taskColor": task.taskColor,

                    // Tehtävän luontiaika tai tyhjä, jos puuttuu
                    "timestamp": task.timestamp || "",

                    // Tehtävän valmistumisaika tai tyhjä, jos puuttuu
                    "completionTime": task.completionTime || ""
                })
            }

            // Debuggausta varten:
            // Tallentaminen asetuksiin
            settings.tasks = JSON.stringify(tasks)

            // Jos tallennuksen aikana tapahtuu virhe
        } catch (e) {

            // Tulostetaan virhe konsoliin
            console.log("Error saving tasks:", e)
        }
    }

    // Your tasks-ikkunan tausta
    Rectangle {

        // Täyttää koko ikkunan
        anchors.fill: parent

        // Väri vaihtuu teeman mukaan
        color: backgroundColor
    }

    // Yläosan header-palkki
    Rectangle {

        // Tunniste, jolla voidaan viitata
        id: header

        // Sama leveys kuin ikkunalla
        width: parent.width

        // Korkeus 60 pikseliä
        height: 60

        // Väri teemasta
        color: headerColor

        // Otsikkoteksti
        Label {

            // Näyttää nykyisen tehtävätilaston
            text: "Your Tasks (" + completedCount + "/" + taskModel.count + ")"

            // Keskitetään headerin sisälle
            anchors.centerIn: parent

            // Fontin koko
            font.pixelSize: 20

            // Tekstin väri
            color: textColor

            // Lihavoitu teksti
            font.bold: true
        }

        // Valikkopainike (Vasen yläreuna)
        Button {

            // Tunniste, jolla komponenttiin voidaan viitata
            id: menuButton

            // Asetetaan vasempaan reunaan
            anchors.left: parent.left

            // 10 pikselin marginaali vasemmalta
            anchors.leftMargin: 10

            // Keskitetään pystysuunnassa
            anchors.verticalCenter: parent.verticalCenter

            // Painikkeen leveys 40 pikseliä
            width: 40

            // Painikkeen korkeus 40 pikseliä
            height: 40

            // Painikkeen teksti
            text: "⋯"

            // Fontin koko
            font.pixelSize: 24

            // Lihavoitu
            font.bold: true

            // Tausta
            background: Rectangle {

                // Läpinäkyvä
                color: "transparent"
            }

            // Painikkeen sisältöteksti
            contentItem: Text {

                // Näytetään kolme pistettä
                text: "⋯"

                // Väri teemasta
                color: textColor

                // Lihavoitu
                font.bold: true

                // Keskitetään vaakasuunnassa
                horizontalAlignment: Text.AlignHCenter

                // Keskitetään pystysuunnassa
                verticalAlignment: Text.AlignVCenter
            }

            // Kun painiketta painetaan
            onClicked: {

                // Avataan päävalikko
                mainMenu.open()
            }
        }

        // Jakopainike
        Button {

            // Tunniste, jolla komponenttiin voidaan viitata
            id: shareButton

            // Asetetaan oikeaan reunaan
            anchors.right: parent.right

            // 10 pikselin marginaali oikealta
            anchors.rightMargin: 10

            // Keskitään pystysuunnassa
            anchors.verticalCenter: parent.verticalCenter

            // Leveys 40 pikseliä
            width: 40

            // Korkeus 40 pikseliä
            height: 40

            // Teksti painikkeessa
            text: "÷"

            // Fontin koko
            font.pixelSize: 18

            // Lihavoitu
            font.bold: true

            // Tausta
            background: Rectangle {

                // Läpinäkyvä
                color: "transparent"
            }

            // Painikkeen sisältö
            contentItem: Text {

                // Jako-symboli
                text: "÷"

                // Väri teemasta
                color: textColor

                // Lihavoitu
                font.bold: true

                // Keskitetään vaakasuunnassa
                horizontalAlignment: Text.AlignHCenter

                // Keskitetään pystysuunnassa
                verticalAlignment: Text.AlignVCenter
            }

            // Kun painiketta painetaan
            onClicked: {

                // Jos tehtäviä on olemassa
                if (taskModel.count > 0) {

                    // Avataan jako-dialogi
                    shareMethodDialog.open()

                    // Jos ei ole yhtään tehtävää jaettavaksi
                } else {

                    // Näytetään ilmoitus:
                    root.showNotification("No tasks to share!")
                }
            }
        }
    }

    // Sovelluksen päävalikko
    Menu {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: mainMenu

        // Teeman vaihtovalinta
        MenuItem {

            // Vaihtoehto riippuu mitä teemaa käyttäjä käyttää nykyisellä hetkellä
            text: darkTheme ? "Switch to Light Theme" : "Switch to Dark Theme"

            // Kun valinta tehdään
            onTriggered: {

                // Vaihdetaan teema vastakkaiseksi
                darkTheme = !darkTheme

                // Tallennetaan asetus sovelluksen muistiin
                settings.theme = darkTheme
            }
        }

        // Valinta: Poista valmiit tehtävät listasta
        MenuItem {

            // Teksti valikossa
            text: "Delete Completed Tasks"

            // Käytössä vain jos on valmiita tehtäviä
            enabled: completedCount > 0

            // Kun valinta tehdään
            onTriggered: {

                // Avataan vahvistusdialogi
                deleteCompletedDialog.open()
            }
        }

        // Valinta: Poista kaikki tehtävät listasta
        MenuItem {

            // Teksti valikossa
            text: "Delete All Tasks"

            // Käytössä vain, jos tehtäviä on
            enabled: taskModel.count > 0

            // Kun valinta tehdään
            onTriggered: {

                // Avataan vahvistusdialogi
                deleteAllDialog.open()
            }
        }
    }

    // Dialogi Valmiiden tehtävien poistolle
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: deleteCompletedDialog
        modal: true

        // Otsikko
        title: "Delete Completed Tasks"

        // Kyllä/Ei -painikkeet
        standardButtons: Dialog.Yes | Dialog.No

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Leveys max 300 pikseliä tai 80% parentista
        width: Math.min(300, parent.width * 0.8)

        // Tausta
        background: Rectangle {

            // Väri teemasta
            color: dialogColor

            // Pyöristetyt kulmat
            radius: 10
        }

        // Dialogin sisältö
        contentItem: Text {

            // Vahvistuskysymys
            text: "Are you sure you want to delete all completed tasks?"

            // Tekstin väri
            color: dialogTextColor

            // Fontin koko
            font.pixelSize: 14

            // Jos teksti on liian pitkä, se rivittyy näytön skaalautuvuuden mukaisesti
            wrapMode: Text.Wrap
        }

        // Jos käyttäjä painaa 'Yes'
        onAccepted: {

            // Käydään tehtävät läpi, ja etsitään 'completed'
            for (var i = taskModel.count - 1; i >= 0; i--) {

                // Jos tehtävä on valmis
                if (taskModel.get(i).completed) {

                    // Tehtävä poistetaan komponentista
                    taskModel.remove(i)
                }
            }

            // Nollataan laskuri
            completedCount = 0

            // Näytetään ilmoitus:
            showNotification("Completed tasks deleted!")
        }
    }

    // Vahvistusdialogi: Poistetaan kaikki tehtävät
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: deleteAllDialog
        modal: true

        // Otsikko
        title: "Delete All Tasks"

        // Kyllä/Ei -painikkeet
        standardButtons: Dialog.Yes | Dialog.No

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Leveys max 300 pikseliä tai 80% parentista
        width: Math.min(300, parent.width * 0.8)

        // Tausta
        background: Rectangle {

            // Väri teemasta
            color: dialogColor

            // Pyöristetyt reunat
            radius: 10
        }

        // Dialogin sisältö
        contentItem: Text {

            // Vahvistuskysymys
            text: "Are you sure you want to delete all tasks?"

            // Tekstin väri
            color: dialogTextColor

            // Fontin koko
            font.pixelSize: 14

            // Jos teksti on liian pitkä, se rivittyy näytön skaalautuvuuden mukaisesti
            wrapMode: Text.Wrap
        }

        // Jos käyttäjä painaa 'Yes'
        onAccepted: {

            // Tyhjennetään koko tehtäväkomponentti
            taskModel.clear()

            // Nollataan laskuri
            completedCount = 0

            // Näytetään ilmoitus
            showNotification("All tasks deleted!")
        }
    }

    // Tallennetaan värin oletusarvo uutta tehtävää varten
    property color currentColor: taskColorDefault

    // Tallennetaan muokattavan tehtävän väri
    property color editCurrentColor: taskColorDefault

    // Tieto siitä, onko uusi tehtävä kiireellinen
    property bool isUrgent: false

    // Tieto siitä, onko muokattava tehtävä kiireellinen
    property bool editIsUrgent: false

    // Uuden tehtävän eräpäivä
    property string currentDueDate: ""

    // Muokattavan tehtävän eräpäivä
    property string editDueDate: ""

    // Uuden tehtävän kuvaus
    property string currentDescription: ""

    // Muokattavan tehtävän kuvaus
    property string editDescription: ""

    // Dialogi, jossa valitaan, miten tehtävät jaetaan (email, Whatsapp, leikepöytä)
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: shareMethodDialog
        modal: true

        // Otsikko
        title: "Share Tasks"

        // Vakionappi, 'Peruuta'
        standardButtons: Dialog.Cancel

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Dialogin leveys suhteessa näytön skaalautuvuuteen (ikkunaan)
        width: Math.min(300, parent.width * 0.8)

        // Tausta pyöristetty suorakulmio
        background: Rectangle {

            // Väri teeman mukaan
            color: dialogColor

            // Pyöristetyt reunat
            radius: 10
        }

        // Sisältö sarakkeessa
        contentItem: Column {

            // Väli nappien välillä
            spacing: 10

            // Email-nappi
            Button {

                // leveys
                width: parent.width

                // Korkeus 50 pikseliä
                height: 50

                // Teksti
                text: "Email"

                // Kun nappia painetaan
                onClicked: {

                    // Suljetaan dialogi
                    shareMethodDialog.close()

                    // Kutsutaan oletussähköposteja tehtävän/tehtävien jakamiseen
                    shareTasks("email")
                }
            }

            // Whatsapp-nappi
            Button {

                // Leveys
                width: parent.width

                // Korkeus 50 pikseliä
                height: 50

                // Teksti
                text: "WhatsApp"

                // Kun nappia painetaan
                onClicked: {

                    // Suljetaan dialogi
                    shareMethodDialog.close()

                    // Kutsutaan Whatsapp jakamiseen
                    shareTasks("whatsapp")
                }
            }

            // Leikepöytään kopiointi -nappi
            Button {

                // Leveys
                width: parent.width

                // Korkeus 50 pikseliä
                height: 50

                // Teksti
                text: "Copy to Clipboard"

                // Kun nappia painetaan
                onClicked: {

                    // Suljetaan dialogi
                    shareMethodDialog.close()

                    // Kopioidaan kaikki tehtävät
                    copyAllTasksToClipboard()
                }
            }
        }
    }

    // Funktio kaikkien tehtävien jakamiseen
    function shareTasks(method) {

        // Luodaan otsikko tehtävälistalle
        var tasksText = "My Tasks:\n\n"

        // Käydään kaikki tehtävät läpi
        for (var i = 0; i < taskModel.count; i++) {

            // Haetaan yksittäinen tehtävä
            var task = taskModel.get(i)

            // Merkitään tehtävän tila
            var status = task.completed ? "[✅]" : "[⏳]"

            // Merkitään kiireellisyys
            var urgency = task.urgent ? " (Urgent)" : ""

            // Lisätään tekstiin
            tasksText += status + " " + task.name + urgency + "\n"

            // Jos kuvaus on annettu
            if (task.description && task.description !== "") {
                tasksText += "   Description: " + task.description + "\n"
            }

            // Jos eräpäivä on annettu
            if (task.dueDate && task.dueDate !== "") {
                tasksText += "   Due Date: " + task.dueDate + "\n"
            }

            // Jos tehtävä on valmis
            if (task.completed && task.completionTime) {

                // Luodaan päivämäärä
                var date = new Date(task.completionTime)
                tasksText += "   Completed: " + formatDate(date) + " " + formatTime(date) + "\n"
            }

            // Tyhjä rivi tehtävien väliin
            tasksText += "\n"
        }

        // Jakotavan valinta
        switch(method) {

            // Lähetetään sähköpostilla
            case "email":
                shareViaEmail(tasksText, "My Tasks")
                break

            // Lähetetään Whatsappissa
            case "whatsapp":
                shareViaWhatsApp(tasksText)
                break

            // Oletuksena sähköpostit
            default:
                shareViaEmail(tasksText, "My Tasks")
        }
    }

    // Funktio Kaikkien tehtävien kopioimiseksi leikepöydälle
    function copyAllTasksToClipboard() {

        // Otsikko tekstille
        var tasksText = "My Tasks:\n\n"

        // Käydään kaikki tehtävät läpi
        for (var i = 0; i < taskModel.count; i++) {

            // Haetaan tehtävä
            var task = taskModel.get(i)

            // Tehtävän status
            var status = task.completed ? "[✅]" : "[⏳]"

            // Kiireellisyys
            var urgency = task.urgent ? " (Urgent)" : ""

            // Kootaan yhteen tehtävän osat
            tasksText += status + " " + task.name + urgency + "\n"

            // Jos kuvaus löytyy
            if (task.description && task.description !== "") {
                tasksText += "   Description: " + task.description + "\n"
            }

            // Jos eräpäivä löytyy
            if (task.dueDate && task.dueDate !== "") {
                tasksText += "   Due Date: " + task.dueDate + "\n"
            }

            // Jos valmis ja valmistumisaika löytyy
            if (task.completed && task.completionTime) {

                // Muutetaan Date-objektiksi
                var date = new Date(task.completionTime)
                tasksText += "   Completed: " + formatDate(date) + " " + formatTime(date) + "\n"
            }

            // Tyhjä rivi
            tasksText += "\n"
        }

        // Jos teksti kopioidaan leikepöydälle
        if (taskTextToClipboard(tasksText)) {

            // Näytetään ilmoitus:
            showNotification("All tasks copied to clipboard!")

            // Jos epäonnistuu, näytetään virheilmoitus
        } else {
            showNotification("Failed to copy to clipboard!")
        }
    }

    // Funktio yhden tehtävän jakamiseen
    function shareSingleTask(index) {

        // Haetaan tehtävä
        var task = taskModel.get(index)

        // Lisätään tehtävän nimi
        var taskText = "Task: " + task.name + "\n"

        // Jos kuvaus löytyy
        if (task.description && task.description !== "") {
            taskText += "Description: " + task.description + "\n"
        }

        // Jos eräpäivä löytyy
        if (task.dueDate && task.dueDate !== "") {
            taskText += "Due Date: " + task.dueDate + "\n"
        }

        // Lisätään tehtävän tila
        taskText += "Status: " + (task.completed ? "Completed" : "Pending") + "\n"

        // Lisätään kiireellisyys
        taskText += "Priority: " + (task.urgent ? "Urgent" : "Not Urgent") + "\n"

        // Jos valmis ja valmistumisaika löytyy
        if (task.completed && task.completionTime) {

            // Muutetaan Date-objektiksi
            var date = new Date(task.completionTime)

            // Lisätään aika
            taskText += "Completed: " + formatDate(date) + " " + formatTime(date) + "\n"
        }

        // Asetetaan teksti dialogille
        shareMethodDialogSingleTask.taskText = taskText

        // Avataan yksittäisen tehtävän jako-dialogi
        shareMethodDialogSingleTask.open()
    }

    // Funktio yhden tehtävän kopiointi leikepöydälle
    function copyTaskToClipboard(index) {

        // Haetaan tehtävä
        var task = taskModel.get(index)

        // Lisätään nimi
        var taskText = "Task: " + task.name + "\n"

        // Jos kuvaus löytyy
        if (task.description && task.description !== "") {
            taskText += "Description: " + task.description + "\n"
        }

        // Jos eräpäivä löytyy
        if (task.dueDate && task.dueDate !== "") {
            taskText += "Due Date: " + task.dueDate + "\n"
        }

        // Lisätään tila
        taskText += "Status: " + (task.completed ? "Completed" : "Pending") + "\n"

        // Lisätään kiireellisyys
        taskText += "Priority: " + (task.urgent ? "Urgent" : "Not Urgent") + "\n"

        // Jos valmis ja valmistumisaika löytyy
        if (task.completed && task.completionTime) {

            // Muutetaan Date-objektiksi
            var date = new Date(task.completionTime)

            // Lisätään valmistumisaika
            taskText += "Completed: " + formatDate(date) + " " + formatTime(date) + "\n"
        }

        // Kopiointi leikepöydälle
        if (taskTextToClipboard(taskText)) {

            // Jos kopiointi onnistuu, näytetään ilmoitus
            showNotification("Task copied to clipboard!")

            // Jos kopiointi epäonnistuu, näytetään ilmoitus
        } else {
            showNotification("Failed to copy to clipboard!")
        }
    }

    // Funktio tehtävätekstin kopioinnille
    function taskTextToClipboard(text) {

        // Yritetään ensin käyttää Qt:n omaa clipboard-API:a
        if (typeof Qt !== 'undefined' && Qt.application && Qt.application.clipboard) {

            // Jos on, asetetaan teksti suoraan leikepöydälle
            Qt.application.clipboard.text = text;
            return true;
        }

        // Fallback: vanha menetelmä TextEditillä (toimii usein paremmin kuin TextArea)
        // Vaihtoehtoinen tapa
        // Debuggausta varten:
        try {

            // Luodaan näkymätön TextEdit-objekti
            var tempInput = Qt.createQmlObject(
                'import QtQuick 2.15; TextEdit { visible: false; selectByMouse: true }',

                // Liitetään 'root'-komponenttiin
                root,

                // Tunniste
                "tempClipboardObject"
            );

            // Asetetaan tekstiksi haluttu sisältö
            tempInput.text = text;

            // Koko teksti
            tempInput.selectAll();

            // Kopioidaan teksti leikepöydälle
            tempInput.copy();

            // Tuhotaan väliaikainen objekti
            tempInput.destroy();
            return true;

            // Jos virhe
        } catch (e) {

            // Tulostetaan virheilmoitus
            console.log("Error copying to clipboard with TextEdit:", e);


            try {

                // Luodaan näkymätön TextEdit-objekti
                var tempInput2 = Qt.createQmlObject(
                    'import QtQuick 2.15; import QtQuick.Controls 2.15; TextArea { visible: false }',

                    // Liitetään root-komponenttiin
                    root,

                    // Tunniste
                    "tempClipboardObject2"
                );

                // Asetetaan tekstiksi haluttu sisältö
                tempInput2.text = text;

                // Koko teksti
                tempInput2.selectAll();

                // Kopioidaan leikepöydälle
                tempInput2.copy();

                // Tuhotaan väliaikainen objekti
                tempInput2.destroy();
                return true;

                // Jos epäonnistuu
            } catch (e2) {

                // Näytetään virheilmoitus
                console.log("Error copying to clipboard with TextArea:", e2);
                return false;
            }
        }
    }

    // Dialog-komponentti yhden tehtävän jakamiseen
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: shareMethodDialogSingleTask
        modal: true

        // Otsikko
        title: "Share Task"

        // Vakionappi 'Peruuta'
        standardButtons: Dialog.Cancel

        // Merkkijono, johon tallennetaan tehtävä
        property string taskText: ""

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Leveys max 300 pikseliä tai 80% ikkunasta
        width: Math.min(300, parent.width * 0.8)

        // Tausta
        background: Rectangle {

            // Väri teemasta
            color: dialogColor

            // Pyöristetyt kulmat
            radius: 10
        }

        // Sisältö sarakkeeseen
        contentItem: Column {

            // Väli elementtien välillä 10 pikseliä
            spacing: 10

            // Email-nappi
            Button {

                // Leveys
                width: parent.width

                // Korkeus 50 pikseliä
                height: 50

                // Teksti
                text: "Email"

                // Kun nappia painetaan
                onClicked: {

                    // Suljetaan dialogi
                    shareMethodDialogSingleTask.close()

                    // Kutsutaan sähköpostin jakoa
                    shareViaEmail(shareMethodDialogSingleTask.taskText, "Task Details")
                }
            }

            // Whatsapp-nappi
            Button {

                // Leveys
                width: parent.width

                // Korkeus 50 pikseliä
                height: 50

                // Teksti
                text: "WhatsApp"

                // Kun nappia painetaan
                onClicked: {

                    // Suljetaan dialogi
                    shareMethodDialogSingleTask.close()

                    // Kutsutaan Whatsapp-jakoa
                    shareViaWhatsApp(shareMethodDialogSingleTask.taskText)
                }
            }

            // Kopiointi-nappi
            Button {

                // Leveys
                width: parent.width

                // Korkeus 50 pikseliä
                height: 50

                // Teksti
                text: "Copy to Clipboard"

                // Kun nappia painetaan
                onClicked: {

                    // Suljetaan dialogi
                    shareMethodDialogSingleTask.close()

                    // Jos kopiointi onnistuu
                    if (taskTextToClipboard(shareMethodDialogSingleTask.taskText)) {

                        // Näytetään ilmoitus
                        showNotification("Task copied to clipboard!")

                        // Jos epäonnistuu, näytetään ilmoitus
                    } else {
                        showNotification("Failed to copy to clipboard!")
                    }
                }
            }
        }
    }

    // Funktio tehtävien jakamiseen sähköpostilla
    function shareViaEmail(text, subject) {

        // Linkki
        var url = "mailto:?body=" + encodeURIComponent(text) + "&subject=" + encodeURIComponent(subject)

        // Avataan järjestelmän oletussähköpostiohjelma
        Qt.openUrlExternally(url)
    }

    // Funktio tehtävien jakamiseen Whatsappilla
    function shareViaWhatsApp(text) {

        // Linkki
        var url = "whatsapp://send?text=" + encodeURIComponent(text)

        // Avataan Whatsapp-sovellus
        Qt.openUrlExternally(url)
    }

    // Kellonaika
    function formatTime(date) {

        // Haetaan tunnit
        var hours = date.getHours()

        // Haetaan minuutit
        var minutes = date.getMinutes()

        // Palautetaan muodossa HH:MM
        return (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes)
    }

    // Funktio, joka muotoilee päivämäärän
    function formatDate(date) {

        // Nykyinen päivä
        var today = new Date()

        // Luodaan kopio nykyisestä päivästä
        var yesterday = new Date(today)

        // Vähennetään yksi päivä, koska laskeminen alkaa nollasta (0, 1, 2)
        yesterday.setDate(yesterday.getDate() - 1)

        // Jos annettu päivä on tänään
        if (date.toDateString() === today.toDateString()) {
            return "today"

            // Jos annettu päivä on eilinen
        } else if (date.toDateString() === yesterday.toDateString()) {
            return "yesterday"

            // Muuten palautetaan normaali päivämäärä
        } else {

            // Päivä.kuukausi.vuosi
            return date.getDate() + "." + (date.getMonth() + 1) + "." + date.getFullYear()
        }
    }

    // Lista, joka näyttää kaikki tehtävät
    ListView {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: taskList

        // Yläreuna headerin alapuolelle
        anchors.top: header.bottom

        // Alareuna footerin yläpuolelle
        anchors.bottom: footer.top

        // Venyy vasempaan reunaan näytönskaalautuvuuden mukaisesti
        anchors.left: parent.left

        // Venyy oikeaan reunaan näytön skaalautuvuuden mukaisesti
        anchors.right: parent.right

        // Komponenttina taskModel
        model: taskModel

        // Väli elementtien välillä
        spacing: 5

        // Rajataan sisältö näkymän sisälle
        clip: true

        // Määritellään listan jaottelu
        section {

            // Jaotellaan tehtävät 'Completed'-arvon mukaan
            property: "completed"

            // Käytetään täyttä merkkijonoa
            criteria: View.FullString

            // Näytetään otsikko
            delegate: Rectangle {

                // Leveys sama kuin listalla
                width: taskList.width

                // Korkeus 30 pikseliä
                height: 30

                // Läpinäkyvä
                color: "transparent"

                // Teksti
                Text {

                    // Vasen reuna venyy näytön skaalautuvuuden mukaisesti
                    anchors.left: parent.left

                    // Vasen marginaali 10 pikseliä
                    anchors.leftMargin: 10

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter

                    // Jos false = 'Waiting', true = 'Completed'
                    text: section == "false" ? "WAITING" : "COMPLETED"

                    // Lihavoitu teksti
                    font.bold: true

                    // Fontin koko
                    font.pixelSize: 16

                    // Väri textColor-muuttujasta
                    color: textColor
                }

                // Alaviiva 'Waiting ja 'Completed otsikon alle
                Rectangle {

                    // Vasen reuna venyy näytön skaalautuvuuden mukaisesti
                    anchors.left: parent.left

                    // Oikea reuna venyy näytön skaalautuvuuden mukaisesti
                    anchors.right: parent.right

                    // Alareuna venyy näytön skaalautuvuuden mukaisesti
                    anchors.bottom: parent.bottom

                    // Korkeus yhden pikselin
                    height: 1

                    // Väri TextColor-muuttujasta
                    color: textColor

                    // Himmennetty (30% näkyvyys)
                    opacity: 0.3
                }
            }
        }

        // Jokaisen tehtävän visuaalinen yksikkö
        delegate: Rectangle {

            // Tunniste, jolla komponenttiin voidaan viitata
            id: taskDelegate

            // Leveys venyy näytön skaalautuvuuden mukaisesti
            width: parent.width

            // Korkeus: sisältökolumnin korkeus + 20 pikseliä
            height: taskContent.height + 20

            // Vaakasuuntainen siirto 5 pikseliä
            x: 5

            // Tehtävän väri tai oletusväri
            color: taskColor || taskColorDefault

            // Pyöristetyt kulmat yhden pikselin verran
            radius: 1

            // Pystysuuntainen sarake
            ColumnLayout {

                // Tunniste, jolla komponenttiin voidaan viitata
                id: taskContent

                // Leveys näytön skaalautuvuuden mukaisesti - 20 pikseliä
                width: parent.width - 20

                // Keskitys
                anchors.centerIn: parent

                // Väli elementtien välillä 5 pikseliä
                spacing: 5

                // Vaakarivi, joka sisältää checkboxin ja tehtävän tiedot
                RowLayout {

                    // Vie saatavilla olevan leveyden
                    Layout.fillWidth: true

                    // Väli elementtien välillä 10 pikseliä
                    spacing: 10

                    // Valintaruutu tehtävän valmiustilalle
                    CheckBox {

                        // Tunniste, jolla komponenttiin voidaan viitata
                        id: taskCheckbox

                        // Completed tai false
                        checked: completed || false

                        // Kun valintaruutua painetaan
                        onClicked: {

                            // Jos painettu
                            if (checked) {

                                // Lisätään tehtävä laskuriin
                                completedCount++

                                // Haetaan nykyinen aika
                                var now = new Date()

                                // Tallennetaan aika ISO-muodossa
                                taskModel.setProperty(index, "completionTime", now.toISOString())

                                // Jos valinta poistetaan
                            } else {

                                // Vähennetään tehtävä laskurista
                                completedCount--

                                // Tyhjennetään aika
                                taskModel.setProperty(index, "completionTime", "")
                            }

                            // Päivitetään 'completed' -arvo
                            taskModel.setProperty(index, "completed", checked)

                            // Lajitellaan tehtävät uudelleen
                            sortTasks()
                        }
                    }

                    // Tehtävän nimi ja kuvaus pystysarakkeessa
                    ColumnLayout {

                        // Vie saatavilla olevan leveyden
                        Layout.fillWidth: true

                        // Väli elementtien välillä 2 pikseliä
                        spacing: 2

                        // Tehtävän nimi
                        Text {
                            Layout.fillWidth: true

                            // Lisätään huutomerkki, jos tehtävä on kiireellinen, muuten tiimalasi
                            text: name + (urgent ? "❗" : " ⏳ ")

                            // Tekstin väri otetaan taskTextColor-muuttujasta
                            color: taskTextColor

                            // Fontin koko
                            font.pixelSize: 16

                            // Lyhennetään tekstin loppu, jos ei mahdu kokonaan tehtävälistalle
                            elide: Text.ElideRight

                            // Yliviivaus, jos tekstin loppu ei mahdu
                            font.strikeout: completed

                            // Tekstin rivittäminen
                            wrapMode: Text.Wrap
                        }

                        // Teksti-muuttuja, tehtävän kuvaus
                        Text {
                            Layout.fillWidth: true
                            text: description

                            // Väri descriptionTextColor-muuttujasta
                            color: descriptionTextColor

                            // Fontin koko
                            font.pixelSize: 12

                            // Lyhennetään tekstin loppu, jos ei mahdu kokonaan tehtävälistalle
                            elide: Text.ElideRight

                            // Tehtävän yliviivaus, jos valmis
                            font.strikeout: completed

                            // Tekstin rivittäminen
                            wrapMode: Text.Wrap

                            // Näytetään vain, jos kuvaus on olemassa
                            visible: description && description !== ""
                        }
                    }

                    // Vasemman yläreunan painike tehtävän toiminnoille
                    Button {

                        // Leveys 40 pikseliä
                        width: 40

                        // Korkeus 40 pikseliä
                        height: 40

                        // Merkki
                        text: "⋮"

                        // Fontin koko
                        font.pixelSize: 18

                        // Lihavoitu
                        font.bold: true

                        // Tausta napille
                        background: Rectangle {

                            // Läpinäkyvä
                            color: "transparent"
                        }

                        // Näytettävä teksti
                        contentItem: Text {

                            // Merkki
                            text: "⋮"

                            // Väri otetaan taskTextColor-muuttujasta
                            color: taskTextColor

                            // Lihavoitu
                            font.bold: true

                            // Vaakasuora tekstin kohdistus
                            horizontalAlignment: Text.AlignHCenter

                            // Pystysuora tekstin kohdistus
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Kun painetaan
                        onClicked: {

                            // Asetetaan valittu tehtävä
                            taskMenu.index = index

                            // Avataan Menu
                            taskMenu.open()
                        }
                    }
                }

                // Tehtävän tiedot -rivi
                RowLayout {

                    // Täyttää annetun sarakkeen
                    Layout.fillWidth: true

                    // Elementtien välillä 10 pikseliä
                    spacing: 10

                    // Eräpäivä
                    Text {

                        // Näytetään eräpäivä
                        visible: dueDate && dueDate !== ""
                        text: "Due: " + dueDate

                        // Aina valkoinen
                        color: "white"

                        // Fontin koko
                        font.pixelSize: 12

                        // Lyhennetään loppu, jos ei mahdu tehtävälistalle
                        elide: Text.ElideRight

                        // Yliviivaus, jos tehtävä on suoritettu
                        font.strikeout: completed
                    }
                }

                // Valmistumisaika
                Text {

                    // Näytetään vain, jos tehtävä on suoritettu
                    visible: completed && completionTime

                    // Täyttää annetun sarakkeen
                    Layout.fillWidth: true

                    // Muotoillaan teksti
                    text: {

                        // Jos valmistumisaika on asetettu
                        if (completionTime) {
                            var date = new Date(completionTime)

                            // Näytetään päivämäärä ja aika
                            return "Completed: " + formatDate(date) + " " + formatTime(date)
                        } else {

                            // Muuten ei näytetä mitään
                            return ""
                        }
                    }

                    // Aina valkoinen, riippumatta teemasta
                    color: "white"

                    // Fontin koko
                    font.pixelSize: 10

                    // Lyhennetään tekstin loppu, jos ei mahdu tehtävälistalle
                    elide: Text.ElideRight
                }
            }

            // Tehtäväkohtainen Menu
            Menu {

                // Tunniste, jolla komponenttiin voidaan viitata
                id: taskMenu

                // Tallennetaan valitun tehtävän indeksi
                property int index: -1

                // Asetetaan menu oikeaan reunaan
                x: parent.width - width

                // Yläreuna
                y: 0

                // Edit-toiminto
                MenuItem {
                    text: "Edit"

                    // Kun painetaan
                    onTriggered: {

                        // Asetetaan muokattava tehtävä dialogiin
                        editDialog.index = taskMenu.index

                        // Haetaan tehtävän tiedot
                        var task = taskModel.get(taskMenu.index)

                        // Asetetaan dialogiin tehtävän nimi
                        editDialog.taskName = task.name

                        // Asetetaan kuvaus
                        editDescription = task.description || ""

                        // Asetetaan eräpäivä
                        editDueDate = task.dueDate || ""

                        // Asetetaan kiireellisyys
                        editIsUrgent = task.urgent || false

                        // Asetetaan väri
                        editCurrentColor = task.taskColor || taskColorDefault

                        // Avataan muokkausdialogi
                        editDialog.open()
                    }
                }

                // 'Delete' valikkokohta
                MenuItem {
                    text: "Delete"

                    // Kun painetaan
                    onTriggered: {

                        // Jos poistettava tehtävä on merkitty tehdyksi
                        if (taskModel.get(taskMenu.index).completed) {

                            // Se poistetaan laskurista
                            completedCount--

                        }

                        // Poistetaan tehtävä taskMenu-komponentista
                        taskModel.remove(taskMenu.index)
                    }
                }

                // 'Share This Task' valikkokohta
                MenuItem {
                    text: "Share This Task"

                    // Kun painetaan
                    onTriggered: {

                        // Kutsutaan funktiota, joka jakaa kyseisen tehtävän
                        shareSingleTask(taskMenu.index)
                    }
                }

                // 'Copy to Clipboard' valikkokohta
                MenuItem {
                    text: "Copy to Clipboard"

                    // Kun painetaan
                    onTriggered: {

                        // Kopioidaan valitun tehtävän tiedot leikepöydälle
                        copyTaskToClipboard(taskMenu.index)
                    }
                }
            }
        }

        // Näytetään huomautus, jos tehtäviä ei ole
        Label {

            // Keskitetään huomautus
            anchors.centerIn: parent

            // Teksti
            text: "No tasks\nClick 'Add Task' to create one"

            // Väri otetaan 'textColor'-muuttujasta
            color: textColor

            // Fontin koko
            font.pixelSize: 16

            // Keskitetään teksti
            horizontalAlignment: Text.AlignHCenter

            // Teksti näytetään vain, jos tehtäviä ei ole
            visible: taskModel.count === 0
        }
    }

    // Footer-osa ikkunan alareunaan
    Rectangle {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: footer

        // Leveys näytön skaalautuvuuden mukaisesti
        width: parent.width

        // Korkeus 60 pikseliä
        height: 60

        // Alareuna
        anchors.bottom: parent.bottom

        // Taustaväri otetaan footerColor-muuttujasta
        color: footerColor

        // Painike footerin sisällä
        Button {

            // Täyttää koko footerin
            anchors.fill: parent

            // Painikkeen teksti
            text: "Add Task"

            // Lihavoitu
            font.bold: true

            // Tausta, läpinäkyvä
            background: Rectangle { color: "transparent" }

            // Painikkeen sisältötekstin määritys
            contentItem: Text {

                // Näytettävä teksti
                text: "Add Task"

                // Sen väri
                color: "#ffffff"

                // Lihavoitu
                font.bold: true

                // Fontin koko
                font.pixelSize: 16

                // Tekstin keskitys vaakasuunnassa
                horizontalAlignment: Text.AlignHCenter

                // Tekstin keskitys pystysuorassa
                verticalAlignment: Text.AlignVCenter
            }

            // Kun painiketta painetaan, avautuu uusi tehtävä -dialogi
            onClicked: createDialog.open()
        }
    }

    // Uuden tehtävän lisäysdialogi
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: createDialog
        modal: true

        // Näytettävä teksti
        title: "Add New Task"

        // Vakionapit, 'OK', ja 'Cancel'
        standardButtons: Dialog.Ok | Dialog.Cancel

        // Keskitys vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitys pystysuunnassa
        y: (parent.height - height) / 2

        // Leveys max 320 pikseliä tai 90% parentista
        width: Math.min(320, parent.width * 0.9)

        // Korkeus 420 pikseliä
        height: 420

        // Dialogin tausta
        background: Rectangle {

            // Väri otetaan 'dialogColor'-muuttujasta
            color: dialogColor

            // Kulmien pyöristys
            radius: 10
        }

        // Sisältö sarakkeessa
        contentItem: Column {

            // Leveys vähän pienempi kuin parentin
            width: parent.width - 20

            // Keskitetään sisältö
            anchors.centerIn: parent

            // Väli elementtien välillä
            spacing: 10

            // Tekstikenttä tehtävän nimeämistä varten
            TextField {

                // Täyttää leveyden
                width: parent.width

                // Tunniste, jolla komponenttiin voidaan viitata
                id: taskInput

                // Harmaa ohjeteksti
                placeholderText: "Task name"

                // Kenttä aktiiviseksi heti dialogin avautuessa
                focus: true

                // Tekstin väri otetaan 'dialogTextColor'-muuttujasta
                color: dialogTextColor

                // Taustalaatikko
                background: Rectangle {

                    // Tummassa tilassa harmaa, muuten valkoinen
                    color: darkTheme ? "#555555" : "white"

                    // Pyöristetyt kulmat
                    radius: 5
                }

                // Kun painetaan
                onAccepted: {

                    // Varmistetaan, ettei kenttä ole tyhjä
                    if (taskInput.text.trim() !== "") {

                        //  Hyväksytään dialogi
                        createDialog.accept()
                    }
                }
            }

            // Tekstikenttä kuvaukselle
            TextField {

                // Täyttää parentin leveyden
                width: parent.width

                // Tunniste, jolla komponenttiin voidaan viitata
                id: descriptionInput

                // Ohjeteksti
                placeholderText: "Description (optional)"

                // Tekstin väri otetaan 'dialogTextColor'-muuttujasta
                color: dialogTextColor

                // Taustalaatikko
                background: Rectangle {

                    // Väri teemasta riippuen
                    color: darkTheme ? "#555555" : "white"

                    // Pyöristetyt kulmat
                    radius: 5
                }
            }

            // Rivi eräpäivän asettamiseen
            Row {

                // Täyttää leveyden
                width: parent.width

                // Väli elementtien välillä 10 pikseliä
                spacing: 10

                // Painike eräpäivän valintaan
                Button {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: dueDateButton

                    // Vie 70 % rivin leveydestä
                    width: parent.width * 0.7

                    // Korkeus 40 pikseliä
                    height: 40

                    // Ohjeteksti
                    text: currentDueDate ? currentDueDate : "Select due date"

                    // Kun painetaan, avataan datePicker-dialogi
                    onClicked: datePicker.open()

                    // Tausta
                    background: Rectangle {

                        // Tummassa tilassa 'Dark gray', muuten valkoinen
                        color: darkTheme ? "#555555" : "white"

                        // Musta reunaviiva
                        border.color: "black"

                        // Pyöristetyt kulmat
                        radius: 5
                    }

                    // Tekstisisältö
                    contentItem: Text {

                        // Sama teksti, kuin painikkeessa
                        text: dueDateButton.text

                        // Tekstin väri otetaan 'dialogTextColor'-muuttujasta
                        color: dialogTextColor

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Keskitetään vasemmalta
                        horizontalAlignment: Text.AlignLeft

                        // Lisätään vasemmalle tyhjää tilaa 10 pikseliä
                        leftPadding: 10
                    }
                }

                // Painike 'Today' -pikavalinnalle
                Button {

                    // Vie 25 % -rivin leveydestä
                    width: parent.width * 0.25

                    // Korkeus 40 pikseliä
                    height: 40

                    // Tekstinä 'Today'
                    text: "Today"

                    // Kun painetaan
                    onClicked: {

                        // Luodaan tämän päivän päivämäärä
                        var today = new Date()

                        // Tallennetaan merkkijonona
                        currentDueDate = today.getDate() + "." + (today.getMonth() + 1) + "." + today.getFullYear()
                    }

                    // Tekstisisältö
                    contentItem: Text {

                        // Tekstinä 'Today'
                        text: "Today"

                        // Musta väri
                        color: "Black"

                        // Fontin koko
                        font.pixelSize: 10

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Rivi kiireellisyysvalinnalle
            Row {

                // Täyttää parentin leveyden
                width: parent.width

                // Väli elementtien välillä viisi pikseliä
                spacing: 5

                // Keskitetään rivi vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Kiireellinen
                Text {

                    // Teksti
                    text: "Urgency:"

                    // Väri otetaan 'dialogTextColor'-muuttujasta
                    color: dialogTextColor

                    // Lihavoitu
                    font.bold: true

                    // Fontin koko
                    font.pixelSize: 12

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Laatikko, joka toimii painikkeena 'Urgent'
                Rectangle {

                    // Leveys 80 pikseliä
                    width: 80

                    // Korkeus 30 pikseliä
                    height: 30

                    // Punainen, jos kiireellinen, muuten teemaväri
                    color: isUrgent ? "#ff6666" : (darkTheme ? "#555555" : "#cccccc")

                    // Reunan väri musta
                    border.color: "Black"

                    // Pyöristetyt reunat
                    radius: 5

                    // Teksti laatikon sisällä
                    Text {

                        // Näytettävä teksti
                        text: "Urgent"

                        // Tumma teemassa valkoinen, muuten musta
                        color: darkTheme ? "white" : "black"

                        // Fontin koko
                        font.pixelSize: 10

                        // Keskitetään laatikon keskelle
                        anchors.centerIn: parent
                    }

                    // alue koko laatikon päällä
                    MouseArea {

                        // Täyttää koko laatikon
                        anchors.fill: parent

                        // Kun painetaan, tehtävä asetetaan kiireelliseksi
                        onClicked: isUrgent = true
                    }
                }

                // Laatikko painikkeelle 'Not Urgent'
                Rectangle {

                    // Leveyden 80 pikseliä
                    width: 80

                    // Korkeus 30 pikseliä
                    height: 30

                    // Vihreä väri, jos ei kiireellinen muuten teemavärin mukaisesti
                    color: !isUrgent ? "#55aa55" : (darkTheme ? "#555555" : "#cccccc")

                    // Musta reunaviiva
                    border.color: "black"

                    // Pyöristetyt kulmat
                    radius: 5

                    // Teksti
                    Text {

                        // Näytettävä teksti
                        text: "Not urgent"

                        // Tummassa tilassa valkoinen, muuten musta
                        color: darkTheme ? "white" : "black"

                        // Fontin koko
                        font.pixelSize: 10

                        // Keskitetään laatikon keskelle
                        anchors.centerIn: parent
                    }



                    // Painettava alue
                    MouseArea {

                        // Täyttää koko laatikon
                        anchors.fill: parent

                        // Kun painetaan, tehtävä asetetaan ei kiireelliseksi
                        onClicked: isUrgent = false
                    }
                }
            }

            // Ohjeteksti värin valintaan
            Text {
                text: "Select color:"

                // Väri otetaan 'dialogTextColor'-muuttujasta
                color: dialogTextColor

                // Lihavoitu
                font.bold: true

                // Fontin koko
                font.pixelSize: 12
            }

            // Värinvalintaruudukko
            Grid {

                // neljä saraketta
                columns: 4

                // kaksi riviä
                rows: 2

                // Rivien väli
                rowSpacing: 5

                // Sarakkeiden väli
                columnSpacing: 5

                // Keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Ruudukon värit
                Repeater {

                    // Värikomponentti
                    model: [
                        taskColorDefault, "#1b1bb6", "#b61b1b", "#1bb61b",
                        "#b61bb6", "#1bb6b6", "#b6b61b", "#b68c1b"
                    ]

                    // Jokaisen värin pystyy valita
                    Rectangle {

                        // Leveys 30 pikseliä
                        width: 30

                        // Korkeus 30 pikseliä
                        height: 30

                        // Väri otetaan 'modelData'-muuttujasta
                        color: modelData

                        // Pyöristetyt kulmat
                        radius: 15

                        // Jos valittu, reuna paksumpi
                        border.width: color === currentColor ? 2 : 1

                        // Reunan väri keltainen, muuten valkoinen
                        border.color: color === currentColor ? "yellow" : "white"

                        // Painettava alue
                        MouseArea {

                            // Täyttää koko laatikon
                            anchors.fill: parent

                            // Painettaessa valittu väri tallennetaan
                            onClicked: currentColor = modelData
                        }
                    }
                }
            }
        }

        // Toiminto, kun dialogi hyväksytään
        onAccepted: {

            // Tehtävän nimi
            var taskName = taskInput.text.trim()

            // Jos nimi ei ole tyhjä
            if (taskName !== "") {

                // Luodaan nykyinen päivämäärä
                var now = new Date()

                // Lisätään uusi tehtävä listaan
                taskModel.append({

                    // Nimi haetaan 'taskName'-muuttujasta
                    "name": taskName,

                    // Kuvaus haetaan 'DescriptionInput'-muuttujasta
                    "description": descriptionInput.text.trim(),

                    // Eräpäivä haetaan 'currentDueDate'-muuttujasta
                    "dueDate": currentDueDate,

                    // Tehtävä tehty = false
                    "completed": false,

                    // Kiireellinen, onko kiireellinen
                    "urgent": isUrgent,

                    // Tehtävän väri tallennetaan merkkijonona
                    "taskColor": currentColor.toString(),

                    // Tallentaa aikaleiman
                    // Milloin luotiin/tallennettiin
                    "timestamp": now.toISOString(),

                    // Luo kentän tehtävän valmistumisajalle
                    // Täytetään vasta, kun tehtävä valmistuu
                    "completionTime": ""
                })


                // Tyhjennetään syötekenttä
                taskInput.text = ""

                // Tyhjennetään kuvauskenttä
                descriptionInput.text = ""

                // Nollataan eräpäivä
                currentDueDate = ""

                // Nollataan kiireellisyys
                isUrgent = false

                // Nollataan väri
                currentColor = taskColorDefault

                // Lajitellaan uusi tehtävä
                sortTasks()
            }
        }

        // Kun dialogi avataan
        onOpened: {

            // Tyhjennetään syätekenttä
            taskInput.text = ""

            // Tyhjennetään kuvauskenttä
            descriptionInput.text = ""

            // Nollataan eräpäivä
            currentDueDate = ""

            // Nollataan kiireellisyys
            isUrgent = false

            // Nollataan väri
            currentColor = taskColorDefault

            // Keskittyy ensimmäiseen tekstikenttään, joka on otsikkokenttä - taskInput
            taskInput.forceActiveFocus()
        }

        // Kun dialogi suljetaan painamalla 'Cancel'
        onRejected: {

            // Tyhjennetään syötekenttä
            taskInput.text = ""

            // Tyhjennetään kuvauskenttä
            descriptionInput.text = ""

            // Nollataan eräpäivä
            currentDueDate = ""

            // Nollataan kiireellisyys
            isUrgent = false

            // Nollataan väri
            currentColor = taskColorDefault
        }
    }

    // DatePicker-dialogi päivämäärän valintaan
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: datePicker
        modal: true

        // Otsikkoteksti
        title: "Select Date"

        // Vakionapit, dialogiin ei tule mitään oletuspainikkeita
        standardButtons: Dialog.NoButton

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Leveys max 320 pikseliä tai 90 % parentista
        width: Math.min(320, parent.width * 0.9)

        // Korkeus 400 pikseliä
        height: 400

        // Tausta
        background: Rectangle {

            // Väri otetaan 'dialogColor'-muuttujasta
            color: dialogColor

            // Pyöristetyt kulmat
            radius: 10
        }

        // Sisältö sarakkeessa
        contentItem: Column {

            // Väli elementtien välillä 20 pikseliä
            spacing: 20

            // Täyttää parentin
            anchors.fill: parent

            // Reunusten marginaali 20 pikseliä
            anchors.margins: 20

            // Näyttää otsikkotekstin
            Text {

                // Itse teksti
                text: "Select Date"

                // Tekstin väri tulee 'textColor'-muuttujasta
                color: textColor

                // Lihavoitu
                font.bold: true

                // Fontin koko
                font.pixelSize: 18

                // Keskitetään vaakasuunnassa parentin sisällä
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Rivi, johon sijoitetaan päivän valinnan elementit
            Row {

                // Rivi vie koko parentin leveyden
                width: parent.width

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Näyttää otsikkotekstin
                Text {

                    // Leveys 70 pikseliä
                    width: 70

                    // Itse teksti
                    text: "Day:"

                    // Väri otetaan 'textColor'-muuttujasta
                    color: textColor

                    // Fontin koko
                    font.pixelSize: 16

                    // Keskitetään pystysuunnassa riviin
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Päivänvalinta
                SpinBox {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: daySpin

                    from: {
                        // Nykyinen päivä
                        var today = new Date();

                        // 'Today'-muuttujaan päivä otetaan kuukauden ja vuoden perusteella
                        if (monthSpin.value === today.getMonth() + 1 && yearSpin.value === today.getFullYear()) {

                            // Päivä otetaan talteen
                            return today.getDate();
                        }

                        // Palautetaan arvo
                        return 1;
                    }

                    // Suurin mahdollinen arvo
                    to: {

                        // Kuukauden päivien määrä
                        return new Date(yearSpin.value, monthSpin.value, 0).getDate();
                    }

                    // Oletusarvo
                    value: {

                        // Nykyinen päivä
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(yearSpin.value, monthSpin.value - 1, daySpin.value);

                        // Jos valittu päivämäärä on menneisyydessä:
                        if (selectedDate < today) {

                            // Palautetaan tämän päivän päivämäärä
                            return today.getDate();
                        }

                        // Muuten palautetaan valittu päivä
                        return daySpin.value;
                    }

                    // Muokattavissa, käyttäjä voi valita haluamansa päivämäärän
                    editable: true

                    // Leveys jättää tilaa labelille
                    width: parent.width - 100

                    // Päivä-Spinboxin sisällä näkyvä teksti
                    contentItem: Text {

                        // Näytetään päivämäärä
                        text: daySpin.textFromValue(daySpin.value, daySpin.locale)

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Fontti otetaan päivä -SpinBoxista
                        font: daySpin.font

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Qt.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Qt.AlignVCenter
                    }

                    // Nuoli oikealle, päivän valitseminen
                    up.indicator: Rectangle {

                        // Asetetaan oikealle tai vasemmalle
                        x: daySpin.mirrored ? 0 : daySpin.width - width

                        // Sama korkeus kuin päivä -SpinBoxilla
                        height: daySpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, tai jos ollaan maksimissa
                        color: daySpin.up.pressed ? (darkTheme ? "#888888" : "#cccccc") : (daySpin.value === daySpin.to ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reuna
                        border.color: "transparent"

                        // Nuolen symboli
                        Text {

                            // Nuoli osoittamaan menosuuntaan
                            text: "→"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa tilassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Keskitetään nuoli laatikon sisään
                            anchors.centerIn: parent
                        }
                    }

                    // Nuoli vasemmalle
                    down.indicator: Rectangle {

                        // Oikealle tai vasemmalle, riippuen peilauksesta
                        x: daySpin.mirrored ? daySpin.width - width : 0

                        // Sama korkeus, kuin päivä -SpinBoxilla
                        height: daySpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, tai jos ollaan minimissä
                        color: daySpin.down.pressed ? (darkTheme ? "#888888" : "#cccccc") : (daySpin.value === daySpin.from ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reuna
                        border.color: "transparent"

                        // Nuolen symboli
                        Text {

                            // Nuoli osoittamaan vasemmalle tulosuuntaan
                            text: "←"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa tilassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Keskitetään nuoli laatikon sisään
                            anchors.centerIn: parent
                        }
                    }

                    // SpinBoxin tausta
                    background: Rectangle {

                        // Oletusleveys 140 pikseliä
                        implicitWidth: 140

                        // Musta reuna
                        border.color: "black"

                        // Läpinökyvä
                        color: "transparent"

                        // Pyöristetyt kulmat
                        radius: 5
                    }

                    //  Kun päivän arvo muuttuu
                    onValueChanged: {

                        // Nykyinen päivä
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(yearSpin.value, monthSpin.value - 1, value);

                        // Jos uusi päivä on menneisyydessä
                        if (selectedDate < today) {

                            // Palautetaan nykyinen päivä
                            value = today.getDate();
                        }
                    }
                }
            }

            // Kuukausirivi
            Row {

                // Vie koko parentin leveyden
                width: parent.width

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Näyttää otsikkotekstin
                Text {

                    // Leveys 70 pikseliä
                    width: 70

                    // Itse teksti
                    text: "Month:"

                    // Väri otetaan 'textColor'-muuttujasta
                    color: textColor

                    // Fontin koko
                    font.pixelSize: 16

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Kuukausivalinta
                SpinBox {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: monthSpin

                    // Alin mahdollinen kuukausi
                    from: {

                        // Nykyinen päivä
                        var today = new Date();

                        // Jos vuosi on tämä vuosi
                        if (yearSpin.value === today.getFullYear()) {

                            // Palautetaan nykyinen kuukausi (koska getMonth() palauttaa arvot 0–11, lisätään +1)
                            return today.getMonth() + 1;
                        }

                        // Muuten alin on Tammikuu (laskeminen alkaa nollasta)
                        return 1;
                    }

                    // Joulukuu 11 + 1
                    to: 12

                    // Oletusarvo
                    value: {

                        // Nykyinen päivä
                        var today = new Date();

                        // Päivämäärä-objekti (vuosi, kuukausi, päivä) käyttäjän antamien arvojen perusteella
                        var selectedDate = new Date(yearSpin.value, value - 1, daySpin.value);

                        // jos valittu päivämäärä on menneisyydessä:
                        if (selectedDate < today) {

                            // Palautetaan nykyinen kuukausi
                            return today.getMonth() + 1;
                        }

                        // Muuten palautetaan käyttäjän antama kuukausi
                        return monthSpin.value;
                    }

                    // Käyttäjä voi syöttää kuukauden
                    editable: true

                    // Vie lähes koko rivin leveyden
                    width: parent.width - 100

                    // Kuukausi-SpinBoxin sisällä näkyvä teksti
                    contentItem: Text {

                        // Kuukauden numero
                        text: monthSpin.textFromValue(monthSpin.value, monthSpin.locale)

                        // Tekstin väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Fontin koko SpinBoxin mukaan
                        font: monthSpin.font

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Qt.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Qt.AlignVCenter
                    }

                    // Nuoli oikealle kuukauden valitsemiseen
                    up.indicator: Rectangle {

                        // Oikealle tai vasemmalle riippuen peilauksesta
                        x: monthSpin.mirrored ? 0 : monthSpin.width - width

                        // Korkeus kuukausi-SpinBoxin mukaan
                        height: monthSpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // // Väri muuttuu painettaessa, tai jos ollaan maksimissa
                        color: monthSpin.up.pressed ? (darkTheme ? "#888888" : "#cccccc") : (monthSpin.value === monthSpin.to ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reuna
                        border.color: "transparent"

                        // Nuoli
                        Text {

                            // Nuoli oikealle menosuuntaan
                            text: "→"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Keskitetään laatikon sisälle
                            anchors.centerIn: parent
                        }
                    }

                    // Kuukauden valitseminen vasemmalle, tulosuuntaan
                    down.indicator: Rectangle {

                        // Oikealle tai vasemmalle riippuen peilauksesta
                        x: monthSpin.mirrored ? monthSpin.width - width : 0

                        // Korkeus kuukausi-SpinBoxin mukaan
                        height: monthSpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, tai jos ollaan minimissä
                        color: monthSpin.down.pressed ? (darkTheme ? "#888888" : "#cccccc") : (monthSpin.value === monthSpin.from ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reuna
                        border.color: "transparent"

                        // Nuoli
                        Text {

                            // Nuoli vasemmalle
                            text: "←"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa tilassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Keskitetään laatikon sisälle
                            anchors.centerIn: parent
                        }
                    }

                    // Kuukausi-SpinBoxin tausta
                    background: Rectangle {

                        // Oletusleveys 140 pikseliä
                        implicitWidth: 140

                        // Musta reunus
                        border.color: "black"

                        // Läpinäkyvä
                        color: "transparent"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Kun kuukauden arvo muuttuu
                    onValueChanged: {

                        // Päivitetään päivien määrä kuukauden vaihtuessa
                        daySpin.to = new Date(yearSpin.value, value, 0).getDate();

                        // Nykyinen päivä
                        var today = new Date();

                        // Päivämäärä-objekti (vuosi, kuukausi, päivä) käyttäjän antamien arvojen perusteella
                        var selectedDate = new Date(yearSpin.value, value - 1, daySpin.value);

                        // Jos valittu päivämäärä on menneisyydessä:
                        if (selectedDate < today) {

                            // Päivitetään nykyiseen päivään
                            daySpin.value = today.getDate();
                        }
                    }
                }
            }

            // Rivi vuodenvalintaan
            Row {

                // Vie koko parentin leveyden
                width: parent.width

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Otsikkoteksti
                Text {

                    // Leveys 70 pikseliä
                    width: 70

                    // Itse teksti
                    text: "Year:"

                    // Väri otetaan 'textColor'-muuttujaan
                    color: textColor

                    // Fontin koko
                    font.pixelSize: 16

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Vuodenvalinta
                SpinBox {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: yearSpin

                    // Alin arvo, jonka käyttäjä voi valita, eli antaa nykyisen vuoden
                    from: new Date().getFullYear()

                    // Enintään 2028-vuoteen asti on mahdollista laittaa tehtäviä
                    // On maksimiarvo
                    to: 2028

                    // Oletusarvo
                    value: {

                        // Nykyinen päivä
                        var today = new Date();

                        // Päivämäärä-objekti (vuosi, kuukausi, päivä) käyttäjän antamien arvojen perusteella
                        var selectedDate = new Date(value, monthSpin.value - 1, daySpin.value);

                        // Jos valittu päivämäärä on menneisyydessä
                        if (selectedDate < today) {

                            // Palautetaan nykyinen vuosi
                            return today.getFullYear();
                        }

                        // Muuten palautetaan käyttäjän antama vuosi
                        return yearSpin.value;
                    }

                    // Käyttäjä voi valita vuosiluvun
                    editable: true

                    // SpinBoxin leveys
                    width: parent.width - 100

                    // SpinBoxin sisällä näkyvä teksti
                    contentItem: Text {

                        // Vuosiluku
                        text: yearSpin.textFromValue(yearSpin.value, yearSpin.locale)

                        // Tekstin väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Fontti otetaan vuosi-SpinBoxista
                        font: yearSpin.font

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Qt.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Qt.AlignVCenter
                    }

                    // Oikea nuoli vuosiluvun valitsemiseen
                    up.indicator: Rectangle {

                        // Oikealle tai vasemmalle peilauksen mukaan
                        x: yearSpin.mirrored ? 0 : yearSpin.width - width

                        // Sama korkeus kuin SpinBoxilla
                        height: yearSpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, tai jos ollaan maksimissa
                        color: yearSpin.up.pressed ? (darkTheme ? "#888888" : "#cccccc") : (yearSpin.value === yearSpin.to ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Musta reuna
                        border.color: "transparent"

                        // Oikea nuoli menosuuntaan
                        Text {

                            // Symboli
                            text: "→"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa tilassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Keskitetään laatikon sisään
                            anchors.centerIn: parent
                        }
                    }

                    // Vasen nuoli tulosuuntaan
                    down.indicator: Rectangle {

                        // Oikealle tai vasemmalle riippuen peilauksesta
                        x: yearSpin.mirrored ? yearSpin.width - width : 0

                        // Korkeus sama, kuin vuosi-Spinboxilla
                        height: yearSpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, tai jos ollaan minimissä
                        color: yearSpin.down.pressed ? (darkTheme ? "#888888" : "#cccccc") : (yearSpin.value === yearSpin.from ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Musta reunus
                        border.color: "transparent"

                        // Nuoli
                        Text {

                            // Symboli
                            text: "←"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa tilassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // keskitetään laatikon sisään
                            anchors.centerIn: parent
                        }
                    }

                    // Vuosi-SpinBoxin tausta
                    background: Rectangle {

                        // Oletusleveys 140 pikseliä
                        implicitWidth: 140

                        // Musta reunus
                        border.color: "black"

                        // Läpinäkyvä
                        color: "transparent"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Kun vuoden arvo muuttuu
                    onValueChanged: {

                        // Päivitetään kuukauden rajoitukset vuoden vaihtuessa
                        monthSpin.from = (value === new Date().getFullYear()) ? new Date().getMonth() + 1 : 1;

                        // Päivitetään päivien määrä
                        daySpin.to = new Date(value, monthSpin.value, 0).getDate();

                        // Nykyinen päivä
                        var today = new Date();

                        // Päivämäärä-objekti (vuosi, kuukausi, päivä) käyttäjän antamien arvojen perusteella
                        var selectedDate = new Date(value, monthSpin.value - 1, daySpin.value);

                        // Jos päivämäärä on menneisyydessä
                        if (selectedDate < today) {

                            // Päivitetään nykyiseen kuukauteen
                            monthSpin.value = today.getMonth() + 1;

                            // Päivitetään nykyiseen päivään
                            daySpin.value = today.getDate();
                        }
                    }
                }
            }

            // Tekstikomponentti, joka näyttää valitun päivämäärän
            Text {

                // Päivämäärä muodossa pv.kk.vvvv
                text: "Selected: " + daySpin.value + "." + monthSpin.value + "." + yearSpin.value

                // Tekstin väri valitaan 'textColor'-muuttujan mukaan
                color: textColor

                // Fontin koko
                font.pixelSize: 16

                // Lihavoitu
                font.bold: true

                // keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Yläreunaan lisätään 10 pikseliä tyhjää tilaa
                topPadding: 10
            }

            // Rivi jossa 'Cancel', 'Clear', ja 'Ok'-painikkeet
            Row {

                // Painikkeiden väli 15 pikseliä
                spacing: 15

                // Keskitetään rivin sisältö vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Yläreunaan lisätään 20 pikseliä tyhjää tilaa
                topPadding: 20

                // 'Cancel'-painike
                Button {

                    // Itse teksti
                    text: "Cancel"

                    // Korkeus 40 pikseliä
                    height: 40

                    // 80 pikseliä
                    width: 80

                    // Suljetaan datePicker, kun painiketta painetaan
                    onClicked: datePicker.close()

                    // Taustana suorakulmio
                    background: Rectangle {

                        // Tummassa teemassa tumman harmaa, muuten vaalean harmaa
                        color: darkTheme ? "#555555" : "#dddddd"

                        // Musta reunus
                        border.color: "black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Painikkeessa näkyvä teksti
                    contentItem: Text {

                        // Itse teksti
                        text: "Cancel"

                        // Väri otetaan 'textColor'-muuttujan mukaan
                        color: textColor

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Lihavoitu
                        font.bold: true
                    }
                }

                // 'Clear'-painike
                Button {

                    // Itse teksti
                    text: "Clear"

                    // Korkeus 40 pikseliä
                    height: 40

                    // Leveys 80 pikseliä
                    width: 80

                    // Kun painetaan
                    onClicked: {

                        // Tyhjennetään nykyinen eräpäivä
                        currentDueDate = ""

                        // Suljetaan 'datePicker'-dialogi
                        datePicker.close()
                    }

                    // Taustana suorakulmio
                    background: Rectangle {

                        // Tummassa teemassa tumman harmaa, muuten vaalean harmaa
                        color: darkTheme ? "#555555" : "#dddddd"

                        // Musta reunus
                        border.color: "black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Painikkeen sisältö
                    contentItem: Text {

                        // Itse teksti
                        text: "Clear"

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Lihavoitu
                        font.bold: true
                    }
                }

                // 'OK'-painike
                Button {

                    // Itse teksti
                    text: "OK"

                    // Korkeus 40 pikseliä
                    height: 40

                    // Leveys 80 pikseliä
                    width: 80

                    // Kun painetaan
                    onClicked: {

                        // Tallennetaan päivämäärä 'currentDueDate'-muuttujaan
                        currentDueDate = daySpin.value + "." + monthSpin.value + "." + yearSpin.value

                        // Suljetaan 'datePicker'-dialogi
                        datePicker.close()
                    }

                    // Taustana suorakulmio
                    background: Rectangle {

                        // Tummassa teemassa tumman harmaa, muuten vaalean harmaa
                        color: darkTheme ? "#555555" : "#dddddd"

                        // Musta reunus
                        border.color: "black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Painikkeessa näkyvä teksti
                    contentItem: Text {

                        // Itse teksti
                        text: "OK"

                        // Tekstin väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Lihavoitu
                        font.bold: true
                    }
                }
            }
        }

        // Suoritetaan, kun 'datePicker'-muuttuja avataan
        onOpened: {

            // Jos nykyinen päivämäärä on olemassa:
            if (currentDueDate) {

                // Jaetaan päivämäärä merkkijonosta muotoon pp.kk.vvvv
                var parts = currentDueDate.split('.');

                // Jos kolme osaa (päivä, kuukausi, vuosi)
                if (parts.length === 3) {

                    // Asetetaan päivä
                    daySpin.value = parseInt(parts[0]);

                    // Asetetaan kuukausi
                    monthSpin.value = parseInt(parts[1]);

                    // Asetetaan vuosi
                    yearSpin.value = parseInt(parts[2]);
                }

                // Jos nykyistä päivämäärää ei ole asetettu
            } else {

                // Haetaan tämän päivän päivämäärä
                var today = new Date();

                // Asetetaan nykyinen päivä
                daySpin.value = today.getDate();

                //Asetetaan nykyinen kuukausi
                monthSpin.value = today.getMonth() + 1;

                // Asetetaan nykyinen vuosi
                yearSpin.value = today.getFullYear();
            }
        }
    }

    // Muokkausdialogi
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: editDialog
        modal: true

        // Otsikkoteksti
        title: "Edit Task"

        // Vakionapit 'OK' ja 'Cancel'
        standardButtons: Dialog.Ok | Dialog.Cancel

        // Tallennetaan muokattavan tehtävän indeksi
        property int index: -1

        // Tallennetaan muokattavan tehtävän nimen
        property string taskName: ""

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Maksimileveys tai 90% parentin leveydestä
        width: Math.min(320, parent.width * 0.9)

        // Korkeus 420 pikseliä
        height: 420

        // Dialogin taustakomponentti
        background: Rectangle {

            // Tekstin väri otetaan 'dialogColor'-muuttujasta
            color: dialogColor

            // Pyöristetyt reunat
            radius: 10
        }

        // Sisältö järjestetään pystysuoraan sarakkeeseen
        contentItem: Column {

            // Leveys täyttää parentin - vähennetään marginaali sivuista
            width: parent.width - 20

            // Keskitetään sisällön sarake dialogissa
            anchors.centerIn: parent

            // Väli elementtien välillä
            spacing: 10

            // Tekstikenttä tehtävän nimeä varten
            TextField {

                // Leveys täyttää parentin
                width: parent.width

                // Tunniste, jolla komponenttiin voidaan viitata
                id: editTaskInput

                // Tehtävän otsikkoteksti näkyy tekstikentässä
                text: editDialog.taskName

                // Jos otsikkoteksti on tyhjä, tekstinä 'Task name'
                placeholderText: "Task name"

                // Automaattinen focus avatessa
                focus: true

                // Tekstin väri 'dialogTextColor'-muuttujan mukaan
                color: dialogTextColor

                // Taustakomponentti
                background: Rectangle {

                    // Tekstin väri tummassa teemassa tumman harmaa, muuten valkoinen
                    color: darkTheme ? "#555555" : "white"

                    // Pyöristetyt reunat
                    radius: 5
                }
            }

            // Tekstikenttä kuvaukselle
            TextField {

                // Leveys täyttää parentin
                width: parent.width

                // Tunniste, jolla komponenttiin voidaan viitata
                id: editDescriptionInput

                // Alkuperäinen kuvaus
                text: editDescription

                // Jos kuvaus on tyhjä, tekstinä 'Description (optional)'
                placeholderText: "Description (optional)"

                // Tekstin väri otetaan 'dialogTextColor'-muuttujasta
                color: dialogTextColor

                // Kentän taustakomponentti
                background: Rectangle {

                    // Tummassa teemassa tumman harmaa, muuten valkoinen
                    color: darkTheme ? "#555555" : "white"

                    // Pyöristetyt reunat
                    radius: 5
                }
            }

            // Rivi, jossa päivämääräpainike
            Row {

                // Rivi täyttää leveyden
                width: parent.width

                // Väli elementtien välillä
                spacing: 10

                // Painike eräpäivävalintaan
                Button {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: editDueDateButton

                    // Leveys 70 % parentista
                    width: parent.width * 0.7

                    // Korkeus 40 pikseliä
                    height: 40

                    // Näyttää nykyisen päivämäärän tai tekstin 'Select due date'
                    text: editDueDate ? editDueDate : "Select due date"

                    // Avataan 'editDatePicker'-dialogi
                    onClicked: editDatePicker.open()

                    // Painikkeen tausta
                    background: Rectangle {

                        // Tummassa teemassa tumman harmaa, muuten valkoinen
                        color: darkTheme ? "#555555" : "white"

                        // Musta reunus
                        border.color: "black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Painikkeen teksti
                    contentItem: Text {

                        // Näytetään 'editDueDateButton'-muuttujapainikkeen teksti
                        text: editDueDateButton.text

                        // Väri otetaan 'dialogTextColor'-muuttujasta
                        color: dialogTextColor

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Kohdistetaan vasemmalle
                        horizontalAlignment: Text.AlignLeft

                        // Vasemmalle 10 pikseliä tyhjää tilaa
                        leftPadding: 10
                    }
                }

                // Painike, jolla asetetaan päivämäärä tämän päivän mukaisesti
                Button {

                    // Leveys 25 % parentista
                    width: parent.width * 0.25

                    // Korkeus 40 pikseliä
                    height: 40

                    // Itse teksti
                    text: "Today"

                    // Kun painetaan
                    onClicked: {

                        // Haetaan tämän päivän päivämäärä
                        var today = new Date()

                        // Asetetaan 'editDueDate'-muuttuja
                        // Muuttaa nykyisen päivämäärän merkkijonoksi (pp.kk.vvvv)
                        editDueDate = today.getDate() + "." + (today.getMonth() + 1) + "." + today.getFullYear()
                    }

                    // Painikkeen tekstikomponentti
                    contentItem: Text {
                        text: "Today"

                        // Musta väri
                        color: "black"

                        // Fontin koko
                        font.pixelSize: 10

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Rivi kiireellisyys-valikoille
            Row {

                // Täyttää parentin leveyden
                width: parent.width

                // Väli komponenttien välillä viisi pikseliä
                spacing: 5

                // Keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Kiireellisyys
                Text {
                    text: "Urgency:"

                    // Väri otetaan 'dialogTextColor'-muuttujasta
                    color: dialogTextColor

                    // Lihavoitu
                    font.bold: true

                    // Fontin koko
                    font.pixelSize: 12

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Urgent-painike suorakulmaisena komponenttina
                Rectangle {

                    // Leveys 80 pikseliä
                    width: 80

                    // Korkeus 30 pikseliä
                    height: 30

                    // Väri punainen, muuten teeman mukainen
                    // Tummassa teemassa harmaa, muuten vaalean harmaa
                    color: editIsUrgent ? "#ff6666" : (darkTheme ? "#555555" : "#cccccc")

                    // Musta reunus
                    border.color: "black"

                    // Pyöristetyt reunat
                    radius: 5

                    // Tekstikomponentti
                    Text {

                        // Itse teksti
                        text: "Urgent"

                        // Tekstin väri teeman mukaan
                        // Tummassa teemassa valkoinen, muuten musta
                        color: darkTheme ? "white" : "black"

                        // Fontin koko
                        font.pixelSize: 10

                        // Keskitetään teksti parentin sisälle
                        anchors.centerIn: parent
                    }

                    // Painallusalue komponentin päällä
                    MouseArea {

                        // Kattaa koko suorakulmion
                        anchors.fill: parent

                        // Kun painetaan, tehtävä muuttuu kiireelliseksi
                        onClicked: editIsUrgent = true
                    }
                }

                // Not urgent -painike suorakulmaisena komponenttina
                Rectangle {

                    // Leveys 80 pikseliä
                    width: 80

                    // Korkeus 30 pikseliä
                    height: 30

                    // Väri vihreä, muuten teeman mukaisesti
                    color: !editIsUrgent ? "#55aa55" : (darkTheme ? "#555555" : "#cccccc")

                    // Musta reunus
                    border.color: "black"

                    // Pyöristetyt reunat
                    radius: 5

                    // Tekstikomponentti
                    Text {

                        // Itse teksti
                        text: "Not urgent"

                        // Tummassa teemassa valkoinen, muuten musta
                        color: darkTheme ? "white" : "black"

                        // Fontin koko
                        font.pixelSize: 10

                        // Teksti keskitetään painikkeen sisälle
                        anchors.centerIn: parent
                    }

                    // Painallusalue komponentin päällä
                    MouseArea {

                        // Kattaa koko suorakulmion
                        anchors.fill: parent

                        // Kun painetaan, tehtävä ei ole kiireellinen
                        onClicked: editIsUrgent = false
                    }
                }
            }

            // Tekstikomponentti värin valitsemiselle
            Text {

                // Itse teksti
                text: "Select color:"

                // Väri otetaan 'dialogTextColor'-muuttujasta
                color: dialogTextColor

                // Lihavoitu
                font.bold: true

                // Fontin koko
                font.pixelSize: 12
            }

            // Värivalinta
            Grid {

                // Neljä saraketta
                columns: 4

                // Kaksi riviä
                rows: 2

                // Rivit erotetaan viidellä pikselillä
                rowSpacing: 5

                // Sarakkeet erotetaan viidellä pikselillä
                columnSpacing: 5

                // Keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Toistaa värivalinnat
                Repeater {

                    // Lista värikoodeista
                    model: [
                        taskColorDefault, "#1b1bb6", "#b61b1b", "#1bb61b",
                        "#b61bb6", "#1bb6b6", "#b6b61b", "#b68c1b"
                    ]

                    // Yksittäinen väriruutu
                    Rectangle {

                        // Leveys 30 pikseliä
                        width: 30

                        // Korkeus 30 pikseliä
                        height: 30

                        // Väri määritetty muuttujassa
                        color: modelData

                        // Ympyrämuotoinen
                        radius: 15

                        // Paksumpi reunaviiva värille, joka on valittuna
                        border.width: color === editCurrentColor ? 2 : 1

                        // Reunaväri keltainen, muuten valkoinen
                        border.color: color === editCurrentColor ? "yellow" : "white"

                        // Painallusalue
                        MouseArea {

                            // Täyttää koko alueen
                            anchors.fill: parent

                            // Painallus asettaa valitun värin
                            onClicked: editCurrentColor = modelData
                        }
                    }
                }
            }
        }

        // Kun dialogi hyväksytään
        onAccepted: {

            // Otetaan alkuperäisen tehtävänimen tilalle uusi
            var taskName = editTaskInput.text.trim()

            // Jos nimi ei ole tyhjä
            if (taskName !== "") {

                // Päivitetään tehtävän nimi komponenttiin
                taskModel.setProperty(editDialog.index, "name", taskName)

                // Päivitetään kuvaus
                taskModel.setProperty(editDialog.index, "description", editDescriptionInput.text.trim())

                // Päivitetään eräpäivä
                taskModel.setProperty(editDialog.index, "dueDate", editDueDate)

                // Päivitetään kiireellisyystila
                taskModel.setProperty(editDialog.index, "urgent", editIsUrgent)

                // Päivitetään tehtävän väri
                taskModel.setProperty(editDialog.index, "taskColor", editCurrentColor.toString())

                // Lajitellaan muutoksen jälkeen
                sortTasks()
            }
        }

        // Kun dialogi avataan
        onOpened: {

            // Haetaan valittu tehtävä komponentista indeksin avulla
            var task = taskModel.get(editDialog.index)

            // Asetetaan tehtävän nimi tekstikenttään
            editTaskInput.text = task.name

            // Asetetaan kuvaus, tai jätetään tyhjäksi, jos puuttuu
            editDescriptionInput.text = task.description || ""

            // Asetetaan eräpäivä, tai jätetään tyhjäksi, jos puuttuu
            editDueDate = task.dueDate || ""

            // Asetetaan kiireellisyys, oletuksena epätosi
            editIsUrgent = task.urgent || false

            // Asetetaan väri, tai oletusväri, jos puuttuu
            editCurrentColor = task.taskColor || taskColorDefault

            // Valitaan koko teksti, helpottaa muokkausta
            editTaskInput.selectAll()

            // Pakottaa fokuksen tehtävänimen tekstikenttään
            editTaskInput.forceActiveFocus()
        }
    }

    // Päivämäärän valinta
    Dialog {

        // Tunniste, jolla komponenttiin voidaan viitata
        id: editDatePicker

        // Estää muiden komponenttien käytön, kun muokkausikkuna on auki
        modal: true

        // Otsikkoteksti
        title: "Select Date"

        // Vakionapit, ei oletuspainikkeita
        standardButtons: Dialog.NoButton

        // Keskitetään vaakasuunnassa
        x: (parent.width - width) / 2

        // Keskitetään pystysuunnassa
        y: (parent.height - height) / 2

        // Maksimileveys 320 pikseliä tai 90 % parentista
        width: Math.min(320, parent.width * 0.9)

        // Korkeus 400 pikseliä
        height: 400

        // Dialogin tausta
        background: Rectangle {

            // Väri otetaan 'dialogColor'-muuttujasta
            color: dialogColor

            // Pyöristetyt reunat
            radius: 10
        }

        // Sisältö pystysuuntaisessa sarakkeessa
        contentItem: Column {

            // Väli elementtien välillä 20 pikseliä
            spacing: 20

            // Täyttää koko parentin
            anchors.fill: parent

            // 20 pikselin marginaalit
            anchors.margins: 20

            // Tekstikomponentti
            Text {

                // Otsikkoteksti
                text: "Select Date"

                // Väri otetaan 'textColor'-muuttujasta
                color: textColor

                // Lihavoitu teksti
                font.bold: true

                // Fontin koko
                font.pixelSize: 18

                // Keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Päivävalinta
            Row {

                // Leveys täyttää koko parentin
                width: parent.width

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Tekstikomponentti
                Text {

                    // Leveys 70 pikseliä
                    width: 70

                    // Otsikkoteksti
                    text: "Day:"

                    // Väri otetaan 'textColor'-muuttujasta
                    color: textColor

                    // Fontin koko 16 pikseliä
                    font.pixelSize: 16

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Päivämäärän valintaboksi
                SpinBox {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: editDaySpin

                    // Minimiarvo
                    from: {

                        // Haetaan tämän päivän päivämäärä
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        if (editMonthSpin.value === today.getMonth() + 1 && editYearSpin.value === today.getFullYear()) {

                            // Palautetaan nykyinen päivä
                            return today.getDate();
                        }

                        // Palautetaan arvo
                        return 1;
                    }

                    // Maksimiarvo
                    to: {

                        // Lasketaan kuukauden päivien määrä
                        return new Date(editYearSpin.value, editMonthSpin.value, 0).getDate();
                    }

                    // Nykyinen arvo
                    value: {
                        // Haetaan tämän päivän päivämäärä
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(editYearSpin.value, editMonthSpin.value - 1, editDaySpin.value);

                        // Jos käyttäjän valitsema päivämäärä on menneisyydessä
                        if (selectedDate < today) {

                            // Asetetaan arvoksi tämänhetkinen päivämäärä
                            return today.getDate();
                        }

                        // Muuten palautetaan käyttäjän valitsema päivä
                        return editDaySpin.value;
                    }

                    // Käyttäjä voi syöttää arvon
                    editable: true

                    // Leveys
                    width: parent.width - 100

                    // Päivä -EditSpinBoxin sisältä
                    contentItem: Text {

                        // Näytettävä numero
                        text: editDaySpin.textFromValue(editDaySpin.value, editDaySpin.locale)

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Fontti 'editDaySpin'-muuttujan mukaan
                        font: editDaySpin.font

                        // Keskitys vaakasuunnassa
                        horizontalAlignment: Qt.AlignHCenter

                        // Keskitys pystysuunnassa
                        verticalAlignment: Qt.AlignVCenter
                    }

                    // Määritellään menosuuntaan menevän nuolen ulkoasu
                    up.indicator: Rectangle {

                        // Jos peilattu, nuoli vasemmalla, muuten oikealla
                        x: editDaySpin.mirrored ? 0 : editDaySpin.width - width

                        // Korkeus sama kuin SpinBoxilla
                        height: editDaySpin.height

                        // Oletusleveys 40 pikseliä
                        implicitWidth: 40

                        // Oletuskorkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, jos ollaan maksimiarvossa = läpinäkyvä
                        color: editDaySpin.up.pressed ? (darkTheme ? "#888888" : "#cccccc") : (editDaySpin.value === editDaySpin.to ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvät reunukset
                        border.color: "transparent"

                        // Tekstikomponentti
                        Text {

                            // Nuoli osoittamaan menosuuntaan
                            text: "→"

                            // Fontin koko 20 pikseliä
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Sijoitetaan keskelle parenttia
                            anchors.centerIn: parent
                        }
                    }

                    // Määritellään tulosuuntaan menevän nuolen ulkoasu
                    down.indicator: Rectangle {

                        // Jos peilattu, nuoli oikealla, muuten vasemmalla
                        x: editDaySpin.mirrored ? editDaySpin.width - width : 0

                        // Korkeus sama kuin SpinBoxilla
                        height: editDaySpin.height

                        // Oletusleveys 40 pikseliä
                        implicitWidth: 40

                        // Oletuskorkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa, jos ollaan maksimiarvossa = läpinäkyvä
                        color: editDaySpin.down.pressed ? (darkTheme ? "#888888" : "#cccccc") : (editDaySpin.value === editDaySpin.from ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reunus
                        border.color: "transparent"

                        // Tekstikomponentti
                        Text {

                            // Nuoli osoittamaan tulosuuntaan
                            text: "←"

                            // Fontin koko 20 pikseliä
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Sijoitetaan parentin keskelle
                            anchors.centerIn: parent
                        }
                    }

                    // Spinboxin tausta
                    background: Rectangle {

                        // Oletusleveys 140 pikseliä
                        implicitWidth: 140

                        // Musta reunus
                        border.color: "black"

                        // Läpinäkyvä
                        color: "transparent"

                        // Pyöristetyt reunat viidellä pikselillä
                        radius: 5
                    }

                    // Kun päivämäärän arvoa muutetaan
                    onValueChanged: {

                        // Tarkistetaan ettei päivämäärä ole menneisyydessä
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(editYearSpin.value, editMonthSpin.value - 1, value);

                        // Jos päivämäärä on menneisyydessä
                        if (selectedDate < today) {

                            // Palautetaan arvoksi nykyinen päivä
                            value = today.getDate();
                        }
                    }
                }
            }

            // Kuukausivalinnan rivielementti
            Row {

                // Leveys täyttää parentin
                width: parent.width

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Tekstikomponentti
                Text {

                    // Leveys 70 pikseliä
                    width: 70

                    // Itse teksti
                    text: "Month:"

                    // Väri otetaan 'textColor'-muuttujasta
                    color: textColor

                    // Fontin koko 16 pikseliä
                    font.pixelSize: 16

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Kuukausivalinta
                SpinBox {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: editMonthSpin

                    // Minimiarvo
                    from: {
                        // Haetaan tämänhetkinen päivämäärä ja aika
                        var today = new Date();

                        // Jos käyttäjän valitsema vuosi on sama kuin nykyinen vuosi,
                        if (editYearSpin.value === today.getFullYear()) {

                            // palautetaan nykyinen kuukausi 1 - 12
                            // +1 koska getMonth() palauttaa arvot 0–11
                            return today.getMonth() + 1;
                        }

                        // Muussa tapauksessa tammikuu
                        return 1;
                    }

                    // Maksimiarvo
                    to: 12

                    // Nykyinen arvo
                    value: {

                        // Haetaan tämänhetkinen päivämäärä ja aika
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(editYearSpin.value, value - 1, editDaySpin.value);

                        // Jos menneisyydessä
                        if (selectedDate < today) {

                            // Palautetaan nykyinen kuukausi
                            return today.getMonth() + 1;
                        }

                        // Muuten käytetään käyttäjän valitsemaa arvoa
                        return editMonthSpin.value;
                    }

                    // Käyttäjä voi syöttää arvon
                    editable: true

                    // Leveys
                    width: parent.width - 100

                    // Teksti, joka näytetään spinboxissa
                    contentItem: Text {

                        // Kuukausi näytetään numerona
                        text: editMonthSpin.textFromValue(editMonthSpin.value, editMonthSpin.locale)

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Fontti 'editMonthSpin'-mukaan
                        font: editMonthSpin.font

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Qt.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Qt.AlignVCenter
                    }

                    // Menosuuntaan menevän nuolen ulkoasu
                    up.indicator: Rectangle {

                        // Jos peilattu, nuoli osoittaa vasemmalle, muuten oikealle
                        x: editMonthSpin.mirrored ? 0 : editMonthSpin.width - width

                        // Korkeus sama kuin spinboxilla
                        height: editMonthSpin.height

                        // Oletusleveys 40 pikseliä
                        implicitWidth: 40

                        // Oletuskorkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa tai kun ollaan maksimiarvossa
                        color: editMonthSpin.up.pressed ? (darkTheme ? "#888888" : "#cccccc") : (editMonthSpin.value === editMonthSpin.to ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reunus
                        border.color: "transparent"

                        // Tekstikomponentti nuolelle
                        Text {

                            // Nuoli oikealle
                            text: "→"

                            // Fontin koko
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Sijoitetaan parentin keskelle
                            anchors.centerIn: parent
                        }
                    }

                    // Vasemmalle osoittavan nuolen ulkoasu
                    down.indicator: Rectangle {

                        // Jos peilattu, nuoli oikealle, muuten vasemmalle
                        x: editMonthSpin.mirrored ? editMonthSpin.width - width : 0

                        // Sama korkeus kuin Spinboxilla
                        height: editMonthSpin.height

                        // Leveys 40 pikseliä
                        implicitWidth: 40

                        // Korkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa tai kun ollaan minimiarvossa
                        color: editMonthSpin.down.pressed ? (darkTheme ? "#888888" : "#cccccc") : (editMonthSpin.value === editMonthSpin.from ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reunus
                        border.color: "transparent"

                        // Tekstielementti
                        Text {

                            // Nuoli osoittamaan tulosuuntaan
                            text: "←"

                            // Fontin koko 20 pikseliä
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Sijoitetaan parentin keskelle
                            anchors.centerIn: parent
                        }
                    }

                    // EditMonth-Spinboxin tausta
                    background: Rectangle {

                        // Oletusleveys 140 pikseliä
                        implicitWidth: 140

                        // Musta reunus
                        border.color: "black"

                        // Läpinäkyvä
                        color: "transparent"

                        // Pyöristetyt reunat viisi pikseliä
                        radius: 5
                    }

                    // Kun kuukauden arvo muuttuu
                    onValueChanged: {

                        // Päivitetään päivien määrä kuukauden vaihtuessa
                        editDaySpin.to = new Date(editYearSpin.value, value, 0).getDate();

                        // Haetaan tämänhetkinen päivämäärä ja aika
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(editYearSpin.value, value - 1, editDaySpin.value);

                        // Jos menneisyydessä:
                        if (selectedDate < today) {

                            // Palautetaan nykyinen päivä
                            editDaySpin.value = today.getDate();
                        }
                    }
                }
            }

            // Vuosivalinnan rivi
            Row {

                // Leveys täyttää parentin
                width: parent.width

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Tekstielementti
                Text {

                    // Leveys 70 pikseliä
                    width: 70

                    // Itse teksti
                    text: "Year:"

                    // Väri otetaan 'textColor'-muuttujasta
                    color: textColor

                    // Fontin koko 16 pikseliä
                    font.pixelSize: 16

                    // Keskitetään pystysuunnassa
                    anchors.verticalCenter: parent.verticalCenter
                }

                // Vuosivalinta-SpinBox
                SpinBox {

                    // Tunniste, jolla komponenttiin voidaan viitata
                    id: editYearSpin

                    // Minimiarvo
                    from: new Date().getFullYear()

                    // Maksimiarvo
                    to: 2028

                    // Nykyinen arvo
                    value: {

                        // Haetaan tämänhetkinen päivämäärä ja aika
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(value, editMonthSpin.value - 1, editDaySpin.value);

                        // Jos valittu päivä menneisyydessä
                        if (selectedDate < today) {

                            // Palautetaan nykyinen päivä
                            return today.getFullYear();
                        }

                        // Muuten palautetaan käyttäjän antama arvo
                        return editYearSpin.value;
                    }

                    // Käyttäjä pystyy valita arvon
                    editable: true

                    // Spinboxin leveys
                    width: parent.width - 100

                    // Näytettävä teksti
                    contentItem: Text {

                        // Vuosi numerona
                        text: editYearSpin.textFromValue(editYearSpin.value, editYearSpin.locale)

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Fontti 'editYeatSpin'-muuttujan mukaan
                        font: editYearSpin.font

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Qt.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Qt.AlignVCenter
                    }

                    // Nuoli menosuuntaan
                    up.indicator: Rectangle {

                        // Jos peilattu, nuoli vasemmalle, muuten oikealle
                        x: editYearSpin.mirrored ? 0 : editYearSpin.width - width

                        // Korkeus sama kuin SpinBoxilla
                        height: editYearSpin.height

                        // Oletusleveys 40 pikseliä
                        implicitWidth: 40

                        // Oletuskorkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa tai kun ollaan maksimiarvossa
                        color: editYearSpin.up.pressed ? (darkTheme ? "#888888" : "#cccccc") : (editYearSpin.value === editYearSpin.to ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reunaviiva
                        border.color: "transparent"

                        // Tekstikomponentti
                        Text {

                            // Nuoli menosuuntaan
                            text: "→"

                            // Fontin koko 20 pikseliä
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Sijoitetaan parentin keskelle
                            anchors.centerIn: parent
                        }
                    }

                    // Vasemmalle osoittavan nuolen ulkoasu
                    down.indicator: Rectangle {

                        // Jos peilattu, nuoli oikealle, muuten vasemmalle
                        x: editYearSpin.mirrored ? editYearSpin.width - width : 0

                        // Korkeus sama kuin SpinBoxilla
                        height: editYearSpin.height

                        // Oletusleveys 40 pikseliä
                        implicitWidth: 40

                        // Oletuskorkeus 40 pikseliä
                        implicitHeight: 40

                        // Väri muuttuu painettaessa tai kun ollaan minimiarvossa
                        color: editYearSpin.down.pressed ? (darkTheme ? "#888888" : "#cccccc") : (editYearSpin.value === editYearSpin.from ? (darkTheme ? "#444444" : "#aaaaaa") : "transparent")

                        // Läpinäkyvä reunus
                        border.color: "transparent"

                        // Tekstikomponentti
                        Text {

                            // Nuoli tulosuuntaan
                            text: "←"

                            // Fontin koko 20 pikseliä
                            font.pixelSize: 20

                            // Tummassa teemassa vaalean harmaa, muuten tumman harmaa
                            color: darkTheme ? "#cccccc" : "#666666"

                            // Sijoitetaan parentin keskelle
                            anchors.centerIn: parent
                        }
                    }

                    // SpinBoxin tausta
                    background: Rectangle {

                        // Oletusleveys 140 pikseliä
                        implicitWidth: 140

                        // Mustat reunukset
                        border.color: "black"

                        // Läpinäkyvä
                        color: "transparent"

                        // Pyöristetyt reunat viidellä pikselillä
                        radius: 5
                    }

                    // Kun vuoden arvo muuttuu
                    onValueChanged: {
                        // Päivitetään kuukausien määrä vuoden vaihtuessa
                        editMonthSpin.from = (value === new Date().getFullYear()) ? new Date().getMonth() + 1 : 1;

                        // Päivitetään päivien määrä
                        editDaySpin.to = new Date(value, editMonthSpin.value, 0).getDate();

                        // Haetaan tämänhetkinen päivämäärä ja aika
                        var today = new Date();

                        // Luo uuden päivämäärä- ja aikaolion
                        var selectedDate = new Date(value, editMonthSpin.value - 1, editDaySpin.value);

                        // Jos valittu päivämäärä on menneisyydessä
                        if (selectedDate < today) {

                            // Palautetaan nykyinen kuukausi
                            editMonthSpin.value = today.getMonth() + 1;

                            // Palautetaan nykyinen päivä
                            editDaySpin.value = today.getDate();
                        }
                    }
                }
            }

            // Tekstikomponentti
            Text {

                // Näyttää käyttäjän valitun päivämäärän
                text: "Selected: " + editDaySpin.value + "." + editMonthSpin.value + "." + editYearSpin.value

                // Väri otetaan 'textColor'-muuttujasta
                color: textColor

                // Fontin koko 16 pikseliä
                font.pixelSize: 16

                // Lihavoitu
                font.bold: true

                // Keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Yläreunan väli 10 pikseliä
                topPadding: 10
            }

            // Rivi 'Cancel', 'Clear', 'OK' -painikkeille
            Row {

                // Väli elementtien välillä 15 pikseliä
                spacing: 15

                // Keskitetään vaakasuunnassa
                anchors.horizontalCenter: parent.horizontalCenter

                // Yläreunan väli 20 pikseliä
                topPadding: 20

                // 'Cancel'-painike
                Button {

                    // Näytettävä teksti
                    text: "Cancel"

                    // Korkeus 40 pikseliä
                    height: 40

                    // Leveys 80 pikseliä
                    width: 80

                    // Kun painetaan, sulkeutuu editDatePicker-ikkuna
                    onClicked: editDatePicker.close()

                    // Tausta
                    background: Rectangle {

                        // Väri tummassa teemassa harmaa, muuten vaalean harmaa
                        color: darkTheme ? "#555555" : "#dddddd"

                        // Musta reunus
                        border.color: "black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Teksti painikkeessa
                    contentItem: Text {
                        text: "Cancel"

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Lihavoitu
                        font.bold: true
                    }
                }

                // 'Clear'-painike
                Button {

                    // Näytettävä teksti
                    text: "Clear"

                    // Korkeus 40 pikseliä
                    height: 40

                    // Leveys 80 pikseliä
                    width: 80

                    // Kun painetaan
                    onClicked: {

                        // Tyhjennetään valittu päivämäärä
                        editDueDate = ""

                        // Suljetaan editDatePicker-ikkna
                        editDatePicker.close()
                    }

                    // Tausta
                    background: Rectangle {

                        // Väri tummassa teemassa harmaa, muuten vaalean harmaa
                        color: darkTheme ? "#555555" : "#dddddd"

                        // Musta reunus
                        border.color: "Black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Teksti painikkeessa
                    contentItem: Text {
                        text: "Clear"

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Lihavoitu
                        font.bold: true
                    }
                }

                // 'OK'-painike
                Button {

                    // Näytettävä teksti
                    text: "OK"

                    // Korkeus 40 pikseliä
                    height: 40

                    // Leveys 80 pikseliä
                    width: 80

                    // Kun painetaan
                    onClicked: {

                        // Tallennetaan päivämäärä
                        editDueDate = editDaySpin.value + "." + editMonthSpin.value + "." + editYearSpin.value

                        // Suljetaan editDatePicker-ikkuna
                        editDatePicker.close()
                    }

                    // Tausta
                    background: Rectangle {

                        // Väri tummassa teemassa harmaa, muuten vaalean harmaa
                        color: darkTheme ? "#555555" : "#dddddd"

                        // Musta reunus
                        border.color: "Black"

                        // Pyöristetyt reunat
                        radius: 5
                    }

                    // Teksti painikkeessa
                    contentItem: Text {
                        text: "OK"

                        // Väri otetaan 'textColor'-muuttujasta
                        color: textColor

                        // Keskitetään vaakasuunnassa
                        horizontalAlignment: Text.AlignHCenter

                        // Keskitetään pystysuunnassa
                        verticalAlignment: Text.AlignVCenter

                        // Lihavoitu
                        font.bold: true
                    }
                }
            }
        }

        // Kun dialogi avataan
        onOpened: {

            // Jos valittu päivämäärä on jo asetettu
            if (editDueDate) {

                // Pilkotaan merkkijono pp.kk.vvvv
                var parts = editDueDate.split('.');

                // Jos osia on kolme
                if (parts.length === 3) {

                    // Asetetaan päivämäärä
                    editDaySpin.value = parseInt(parts[0]);

                    // Asetetaan kuukausi
                    editMonthSpin.value = parseInt(parts[1]);

                    // Asetetaan vuosi
                    editYearSpin.value = parseInt(parts[2]);
                }

                // Jos päivämäärää ei ole asetettu
            } else {

                // Haetaan tämänhetkinen päivämäärä ja aika
                var today = new Date();

                // Palautetaan nykyinen päivä
                editDaySpin.value = today.getDate();

                // Palautetaan nykyinen kuukausi
                editMonthSpin.value = today.getMonth() + 1;

                // Palautetaan nykyinen vuosi
                editYearSpin.value = today.getFullYear();
            }
        }
    }
}
