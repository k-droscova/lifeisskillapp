// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Basic {
    /// Upozornění
    internal static let attention = L10n.tr("Localizable", "basic.attention", fallback: "Upozornění")
    /// Zavřít
    internal static let close = L10n.tr("Localizable", "basic.close", fallback: "Zavřít")
    /// Chyba
    internal static let error = L10n.tr("Localizable", "basic.error", fallback: "Chyba")
    /// Ukončit
    internal static let finish = L10n.tr("Localizable", "basic.finish", fallback: "Ukončit")
    /// OK
    internal static let ok = L10n.tr("Localizable", "basic.ok", fallback: "OK")
    /// Načítám
    internal static let refresh = L10n.tr("Localizable", "basic.refresh", fallback: "Načítám")
    /// Více
    internal static let showMore = L10n.tr("Localizable", "basic.show_more", fallback: "Více")
    /// Použít
    internal static let use = L10n.tr("Localizable", "basic.use", fallback: "Použít")
    internal enum Error {
      /// Vyskytla se chyba
      internal static let message = L10n.tr("Localizable", "basic.error.message", fallback: "Vyskytla se chyba")
    }
  }
  internal enum Events {
    /// Žádné nadcházející události
    internal static let placeholder = L10n.tr("Localizable", "events.placeholder", fallback: "Žádné nadcházející události")
    /// Akce
    internal static let title = L10n.tr("Localizable", "events.title", fallback: "Akce")
  }
  internal enum Home {
    /// Bodů: %d
    internal static func points(_ p1: Int) -> String {
      return L10n.tr("Localizable", "home.points", p1, fallback: "Bodů: %d")
    }
    /// Načíst body
    internal static let title = L10n.tr("Localizable", "home.title", fallback: "Načíst body")
    internal enum Button {
      /// jak na to?
      internal static let how = L10n.tr("Localizable", "home.button.how", fallback: "jak na to?")
    }
    internal enum Description {
      /// Bod se ti přičte přiblížením telefonu ke značce a načtením pomocí NFC. Můžeš použít také čtení QR kódu.
      internal static let nfc = L10n.tr("Localizable", "home.description.nfc", fallback: "Bod se ti přičte přiblížením telefonu ke značce a načtením pomocí NFC. Můžeš použít také čtení QR kódu.")
      /// Bod se ti přičte stisknutím tlačítka "Načíst QR kód" a namířením fotoaparátu telefonu na QR kód.
      internal static let qr = L10n.tr("Localizable", "home.description.qr", fallback: "Bod se ti přičte stisknutím tlačítka \"Načíst QR kód\" a namířením fotoaparátu telefonu na QR kód.")
      /// Načti bod v tvé blízkosti
      internal static let title = L10n.tr("Localizable", "home.description.title", fallback: "Načti bod v tvé blízkosti")
    }
    internal enum Nfc {
      /// Přiložte NFC čip na horní část zadní strany telefonu.
      internal static let alerMessage = L10n.tr("Localizable", "home.nfc.aler_message", fallback: "Přiložte NFC čip na horní část zadní strany telefonu.")
      /// Načíst NFC
      internal static let button = L10n.tr("Localizable", "home.nfc.button", fallback: "Načíst NFC")
      /// Přiložte NFC čip na horní čás zadní strany telefonu.
      internal static let scanAlert = L10n.tr("Localizable", "home.nfc.scan_alert", fallback: "Přiložte NFC čip na horní čás zadní strany telefonu.")
    }
    internal enum Qr {
      /// Načíst QR kód
      internal static let button = L10n.tr("Localizable", "home.qr.button", fallback: "Načíst QR kód")
      /// Zaměřte fotoaparát na platný LiS QR kód
      internal static let scanAlert = L10n.tr("Localizable", "home.qr.scan_alert", fallback: "Zaměřte fotoaparát na platný LiS QR kód")
      /// Použít qr kód
      internal static let useQr = L10n.tr("Localizable", "home.qr.use_qr", fallback: "Použít qr kód")
      internal enum Permission {
        /// Použití fotoaparátu musí být povoleno. Bez fotoaparátu nemůžete načítat QR kódy.
        internal static let message = L10n.tr("Localizable", "home.qr.permission.message", fallback: "Použití fotoaparátu musí být povoleno. Bez fotoaparátu nemůžete načítat QR kódy.")
        /// Otevřít nastavení
        internal static let setting = L10n.tr("Localizable", "home.qr.permission.setting", fallback: "Otevřít nastavení")
        /// Povolte fotoaparát
        internal static let title = L10n.tr("Localizable", "home.qr.permission.title", fallback: "Povolte fotoaparát")
      }
    }
    internal enum ScanError {
      /// Opakovat
      internal static let again = L10n.tr("Localizable", "home.scan_error.again", fallback: "Opakovat")
      /// Bod byl naskenován, ale telefon není připojen k internetu. Bod byl uložen a bude ověřen až se připojíte k internetu. Zkontrolujte připojení k internetu.
      internal static let noInternet = L10n.tr("Localizable", "home.scan_error.no_internet", fallback: "Bod byl naskenován, ale telefon není připojen k internetu. Bod byl uložen a bude ověřen až se připojíte k internetu. Zkontrolujte připojení k internetu.")
      /// Při ověřování bodu nastala chyba. Ověřte připojení k internetu, polohové služby a vyzkoušejte bod načíst znovu.
      internal static let requestError = L10n.tr("Localizable", "home.scan_error.request_error", fallback: "Při ověřování bodu nastala chyba. Ověřte připojení k internetu, polohové služby a vyzkoušejte bod načíst znovu.")
      internal enum Nfc {
        /// Toto NFC není naše. 
        ///  Naskenujte Life is Skill NFC.
        internal static let message = L10n.tr("Localizable", "home.scan_error.nfc.message", fallback: "Toto NFC není naše. \n Naskenujte Life is Skill NFC.")
      }
      internal enum Qr {
        /// Tento QR kód není platný. 
        ///  Naskenujte Life is Skill QR kód.
        internal static let message = L10n.tr("Localizable", "home.scan_error.qr.message", fallback: "Tento QR kód není platný. \n Naskenujte Life is Skill QR kód.")
      }
    }
    internal enum ScanSuccess {
      /// Bod ještě projde validací a bude přičten.
      internal static let message = L10n.tr("Localizable", "home.scan_success.message", fallback: "Bod ještě projde validací a bude přičten.")
      /// Skenovat další
      internal static let next = L10n.tr("Localizable", "home.scan_success.next", fallback: "Skenovat další")
      /// Bod byl naskenován
      internal static let title = L10n.tr("Localizable", "home.scan_success.title", fallback: "Bod byl naskenován")
    }
  }
  internal enum Location {
    /// Musíš povolit polohové služby pro tuto aplikaci v nastavení. 
    ///  1. Nastavení 
    ///  2. Dole najít LiSApp 
    ///  3. Poloha 
    ///  4. Vybrat "při používání aplikace"
    internal static let denied = L10n.tr("Localizable", "location.denied", fallback: "Musíš povolit polohové služby pro tuto aplikaci v nastavení. \n 1. Nastavení \n 2. Dole najít LiSApp \n 3. Poloha \n 4. Vybrat \"při používání aplikace\"")
    /// Nelze použít polohové služby. (problém může souviset s rodičovskou kontrolou) Musíš povolit polohové služby, jinak nemůžeš načítat body ani používat mapu. 
    ///  1. Nastavení 
    ///  2. Soukromí 
    ///  3. Polohové služby 
    ///  4. Zapnout
    internal static let restricted = L10n.tr("Localizable", "location.restricted", fallback: "Nelze použít polohové služby. (problém může souviset s rodičovskou kontrolou) Musíš povolit polohové služby, jinak nemůžeš načítat body ani používat mapu. \n 1. Nastavení \n 2. Soukromí \n 3. Polohové služby \n 4. Zapnout")
    /// Localizable.strings
    ///   lifeisskillapp
    /// 
    ///   Created by Karolína Droscová on 13.07.2024.
    internal static let servicesDisabled = L10n.tr("Localizable", "location.services_disabled", fallback: "Musíš povolit polohové služby, jinak nemůžeš načítat body ani používat mapu. \n 1. Nastavení \n 2. Soukromí \n 3. Polohové služby \n 4. Zapnout")
  }
  internal enum Login {
    /// Přihlásit se
    internal static let login = L10n.tr("Localizable", "login.login", fallback: "Přihlásit se")
    /// Heslo
    internal static let password = L10n.tr("Localizable", "login.password", fallback: "Heslo")
    /// Vytvořit nový účet
    internal static let register = L10n.tr("Localizable", "login.register", fallback: "Vytvořit nový účet")
    /// Vítejte zpět!
    internal static let title = L10n.tr("Localizable", "login.title", fallback: "Vítejte zpět!")
    /// Email/uživatelské jméno
    internal static let username = L10n.tr("Localizable", "login.username", fallback: "Email/uživatelské jméno")
    internal enum Error {
      /// Vyplňte všechny položky.
      internal static let emptyFields = L10n.tr("Localizable", "login.error.emptyFields", fallback: "Vyplňte všechny položky.")
      /// Zadali jste neplatné přihlašovací údaje.
      internal static let invalidCredentials = L10n.tr("Localizable", "login.error.invalid_credentials", fallback: "Zadali jste neplatné přihlašovací údaje.")
      /// Chyba sítě. Připojte se k internetu.
      internal static let network = L10n.tr("Localizable", "login.error.network", fallback: "Chyba sítě. Připojte se k internetu.")
      /// Chyba server. Připojte se později.
      internal static let server = L10n.tr("Localizable", "login.error.server", fallback: "Chyba server. Připojte se později.")
    }
  }
  internal enum Map {
    /// Mapa
    internal static let title = L10n.tr("Localizable", "map.title", fallback: "Mapa")
    internal enum RouteButton {
      /// Navigovat
      internal static let title = L10n.tr("Localizable", "map.route_button.title", fallback: "Navigovat")
    }
  }
  internal enum Messages {
    /// Zprávy
    internal static let title = L10n.tr("Localizable", "messages.title", fallback: "Zprávy")
  }
  internal enum Onboarding {
    internal enum Description {
      /// Užij si danou aktivitu.
      internal static let activity = L10n.tr("Localizable", "onboarding.description.activity", fallback: "Užij si danou aktivitu.")
      /// Pomocí mapy najdi umístění LiS čipů.
      internal static let find = L10n.tr("Localizable", "onboarding.description.find", fallback: "Pomocí mapy najdi umístění LiS čipů.")
      /// Načti čip telefonem přes NFC nebo QR kód.
      internal static let point = L10n.tr("Localizable", "onboarding.description.point", fallback: "Načti čip telefonem přes NFC nebo QR kód.")
      /// Soutěž s ostatními a vyhraj hodnotné ceny.
      internal static let prizes = L10n.tr("Localizable", "onboarding.description.prizes", fallback: "Soutěž s ostatními a vyhraj hodnotné ceny.")
      /// V případě jakýchkoliv problémů nás kontaktuj na info@lifeisskill.cz
      internal static let problems = L10n.tr("Localizable", "onboarding.description.problems", fallback: "V případě jakýchkoliv problémů nás kontaktuj na info@lifeisskill.cz")
      /// Svůj účet můžeš také spravovat na www.muj.lifeisskill.cz
      internal static let web = L10n.tr("Localizable", "onboarding.description.web", fallback: "Svůj účet můžeš také spravovat na www.muj.lifeisskill.cz")
    }
  }
  internal enum PointList {
    /// Bod
    internal static let point = L10n.tr("Localizable", "point_list.point", fallback: "Bod")
    /// Účet
    internal static let title = L10n.tr("Localizable", "point_list.title", fallback: "Účet")
    internal enum Outbox {
      /// Několik bodů čeká na odeslání k validaci. Připojte se k internetu.
      internal static let cell = L10n.tr("Localizable", "point_list.outbox.cell", fallback: "Několik bodů čeká na odeslání k validaci. Připojte se k internetu.")
      /// Vyskytl se problém s připojením. %d načtených čipů čeká na validaci.
      internal static func more(_ p1: Int) -> String {
        return L10n.tr("Localizable", "point_list.outbox.more", p1, fallback: "Vyskytl se problém s připojením. %d načtených čipů čeká na validaci.")
      }
      /// Vyskytl se problém s připojením. Načtený čip čeká na validaci.
      internal static let one = L10n.tr("Localizable", "point_list.outbox.one", fallback: "Vyskytl se problém s připojením. Načtený čip čeká na validaci.")
      /// Neodeslané body
      internal static let title = L10n.tr("Localizable", "point_list.outbox.title", fallback: "Neodeslané body")
      /// Vyskytl se problém s připojením. %d načtené čipy čekají na validaci.
      internal static func twoFour(_ p1: Int) -> String {
        return L10n.tr("Localizable", "point_list.outbox.two_four", p1, fallback: "Vyskytl se problém s připojením. %d načtené čipy čekají na validaci.")
      }
      /// Načtený bod
      internal static let unknownCell = L10n.tr("Localizable", "point_list.outbox.unknownCell", fallback: "Načtený bod")
      internal enum Help {
        /// Telefon není připojen k internetu a proto nelze některé načtené body ověřit. Připojte se k internetu a vyčkejte. Body se automaticky odešlou po připojení k internetu. 
        ///  
        ///  Pokud načtete stejný bod vícekrát v jedné minutě, pak se uloží nejnovější (poslední) načtení.
        internal static let description = L10n.tr("Localizable", "point_list.outbox.help.description", fallback: "Telefon není připojen k internetu a proto nelze některé načtené body ověřit. Připojte se k internetu a vyčkejte. Body se automaticky odešlou po připojení k internetu. \n \n Pokud načtete stejný bod vícekrát v jedné minutě, pak se uloží nejnovější (poslední) načtení.")
        /// Připojení k internetu je zřejmě neaktivní
        internal static let title = L10n.tr("Localizable", "point_list.outbox.help.title", fallback: "Připojení k internetu je zřejmě neaktivní")
      }
    }
    internal enum PointsSum {
      /// %d bodů
      internal static func more(_ p1: Int) -> String {
        return L10n.tr("Localizable", "point_list.points_sum.more", p1, fallback: "%d bodů")
      }
      /// %d bod
      internal static func one(_ p1: Int) -> String {
        return L10n.tr("Localizable", "point_list.points_sum.one", p1, fallback: "%d bod")
      }
      /// %d body
      internal static func twoFour(_ p1: Int) -> String {
        return L10n.tr("Localizable", "point_list.points_sum.two_four", p1, fallback: "%d body")
      }
    }
  }
  internal enum Prizes {
    /// Výhry
    internal static let title = L10n.tr("Localizable", "prizes.title", fallback: "Výhry")
    internal enum Header {
      /// Níže uvádíme ukázku výher z minulé sezony
      internal static let description = L10n.tr("Localizable", "prizes.header.description", fallback: "Níže uvádíme ukázku výher z minulé sezony")
      /// Výhry na sezonu 2020/2021 pro vás připravujeme
      internal static let title = L10n.tr("Localizable", "prizes.header.title", fallback: "Výhry na sezonu 2020/2021 pro vás připravujeme")
    }
  }
  internal enum Register {
    /// Údaje rodiče
    internal static let parentInfo = L10n.tr("Localizable", "register.parent_info", fallback: "Údaje rodiče")
    /// Údaje uživatele
    internal static let userInfo = L10n.tr("Localizable", "register.user_info", fallback: "Údaje uživatele")
    internal enum Button {
      /// Zrušit
      internal static let cancel = L10n.tr("Localizable", "register.button.cancel", fallback: "Zrušit")
      /// Registrovat
      internal static let done = L10n.tr("Localizable", "register.button.done", fallback: "Registrovat")
      /// Další
      internal static let next = L10n.tr("Localizable", "register.button.next", fallback: "Další")
      /// Předchozí
      internal static let previous = L10n.tr("Localizable", "register.button.previous", fallback: "Předchozí")
    }
    internal enum Error {
      /// Pole nesmí být prázdné
      internal static let empty = L10n.tr("Localizable", "register.error.empty", fallback: "Pole nesmí být prázdné")
      /// Neplatná emailová adresa
      internal static let invalidMail = L10n.tr("Localizable", "register.error.invalid_mail", fallback: "Neplatná emailová adresa")
      /// Neplatné telefonní číslo
      internal static let invalidPhone = L10n.tr("Localizable", "register.error.invalid_phone", fallback: "Neplatné telefonní číslo")
      /// Neplatné poštovní směrovací číslo
      internal static let invalidPostcode = L10n.tr("Localizable", "register.error.invalid_postcode", fallback: "Neplatné poštovní směrovací číslo")
      /// Používané uživatelské jméno
      internal static let invalidUsername = L10n.tr("Localizable", "register.error.invalid_username", fallback: "Používané uživatelské jméno")
      /// Email nesmí být stejný jako email uživatele
      internal static let parrentEmail = L10n.tr("Localizable", "register.error.parrent_email", fallback: "Email nesmí být stejný jako email uživatele")
      /// Hesla se neshodují
      internal static let passwordNotMatch = L10n.tr("Localizable", "register.error.password_not_match", fallback: "Hesla se neshodují")
      /// 
      internal static let shortName = L10n.tr("Localizable", "register.error.short_name", fallback: "")
      /// 
      internal static let shortRelationship = L10n.tr("Localizable", "register.error.short_relationship", fallback: "")
      /// 
      internal static let shortSurname = L10n.tr("Localizable", "register.error.short_surname", fallback: "")
      /// Minimálně 3 znaky
      internal static let shortUsername = L10n.tr("Localizable", "register.error.short_username", fallback: "Minimálně 3 znaky")
      /// Používaná emailová adresa
      internal static let usedMail = L10n.tr("Localizable", "register.error.used_mail", fallback: "Používaná emailová adresa")
      /// Min 5 znaků, číslice, malé a velké písmeno
      internal static let weakPassword = L10n.tr("Localizable", "register.error.weak_password", fallback: "Min 5 znaků, číslice, malé a velké písmeno")
      internal enum Age {
        /// Hra je pro uživatele do 18 let
        internal static let old = L10n.tr("Localizable", "register.error.age.old", fallback: "Hra je pro uživatele do 18 let")
        /// Hra je pro uživatele od 6 let
        internal static let young = L10n.tr("Localizable", "register.error.age.young", fallback: "Hra je pro uživatele od 6 let")
      }
    }
    internal enum Field {
      /// Datum narození
      internal static let birth = L10n.tr("Localizable", "register.field.birth", fallback: "Datum narození")
      /// Pro pokračování je nutné vyslovit souhlas s GDPR. Bližší informace se dozvíte zde.
      internal static let gdpr = L10n.tr("Localizable", "register.field.gdpr", fallback: "Pro pokračování je nutné vyslovit souhlas s GDPR. Bližší informace se dozvíte zde.")
      /// Pohlaví
      internal static let gender = L10n.tr("Localizable", "register.field.gender", fallback: "Pohlaví")
      /// Email
      internal static let mail = L10n.tr("Localizable", "register.field.mail", fallback: "Email")
      /// Jméno
      internal static let name = L10n.tr("Localizable", "register.field.name", fallback: "Jméno")
      /// Heslo
      internal static let password = L10n.tr("Localizable", "register.field.password", fallback: "Heslo")
      /// Mobil
      internal static let phone = L10n.tr("Localizable", "register.field.phone", fallback: "Mobil")
      /// PSČ
      internal static let postNumber = L10n.tr("Localizable", "register.field.post_number", fallback: "PSČ")
      /// Vztah
      internal static let relationship = L10n.tr("Localizable", "register.field.relationship", fallback: "Vztah")
      /// Heslo znovu
      internal static let secondPassword = L10n.tr("Localizable", "register.field.second_password", fallback: "Heslo znovu")
      /// Příjmení
      internal static let surname = L10n.tr("Localizable", "register.field.surname", fallback: "Příjmení")
      /// Přezdívka
      internal static let username = L10n.tr("Localizable", "register.field.username", fallback: "Přezdívka")
      internal enum Gender {
        /// Ženské
        internal static let female = L10n.tr("Localizable", "register.field.gender.female", fallback: "Ženské")
        /// Mužské
        internal static let male = L10n.tr("Localizable", "register.field.gender.male", fallback: "Mužské")
      }
    }
    internal enum Success {
      /// Právě proběhla registrace nového uživatele. Pro plnou funkčnost je nutno účet aktivovat v OBOU emailech. Pokračujte do emailu rodiče, kde jsou další podrobnosti. Účet musíte ověřit nejdříve na emailu rodiče a poté na emailu uživatele. Účet je možné ověřit do 7 dnů od vytvoření registrace.
      internal static let message = L10n.tr("Localizable", "register.success.message", fallback: "Právě proběhla registrace nového uživatele. Pro plnou funkčnost je nutno účet aktivovat v OBOU emailech. Pokračujte do emailu rodiče, kde jsou další podrobnosti. Účet musíte ověřit nejdříve na emailu rodiče a poté na emailu uživatele. Účet je možné ověřit do 7 dnů od vytvoření registrace.")
      /// Jste skoro zaregistrován
      internal static let title = L10n.tr("Localizable", "register.success.title", fallback: "Jste skoro zaregistrován")
    }
  }
  internal enum Settings {
    /// Nastavení
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Nastavení")
    internal enum Field {
      internal enum Account {
        /// Můj profil
        internal static let title = L10n.tr("Localizable", "settings.field.account.title", fallback: "Můj profil")
      }
      internal enum Avatar {
        /// Avatar
        internal static let title = L10n.tr("Localizable", "settings.field.avatar.title", fallback: "Avatar")
      }
      internal enum Contact {
        /// Nahlásit problém
        internal static let title = L10n.tr("Localizable", "settings.field.contact.title", fallback: "Nahlásit problém")
      }
      internal enum Info {
        /// O aplikaci
        internal static let title = L10n.tr("Localizable", "settings.field.info.title", fallback: "O aplikaci")
      }
      internal enum Manual {
        /// Nápověda
        internal static let title = L10n.tr("Localizable", "settings.field.manual.title", fallback: "Nápověda")
      }
      internal enum Notifications {
        /// Upozornění
        internal static let title = L10n.tr("Localizable", "settings.field.notifications.title", fallback: "Upozornění")
      }
      internal enum Prize {
        /// Výhry
        internal static let title = L10n.tr("Localizable", "settings.field.prize.title", fallback: "Výhry")
      }
      internal enum Rules {
        /// Pravidla hry
        internal static let title = L10n.tr("Localizable", "settings.field.rules.title", fallback: "Pravidla hry")
      }
      internal enum Share {
        /// Pojď semnou hrát LifeIsSkill hru. Můžeš vyhrát dovolenou, vyhlídkový let nebo kolo. 🎁 Je to jednoduché. Stáhni aplikaci, sbírej body a vyhraj skvělé ceny. 🏅 (určeno pro hráče ve věku od 6 do 18 let)"
        internal static let inviteMessage = L10n.tr("Localizable", "settings.field.share.invite_message", fallback: "Pojď semnou hrát LifeIsSkill hru. Můžeš vyhrát dovolenou, vyhlídkový let nebo kolo. 🎁 Je to jednoduché. Stáhni aplikaci, sbírej body a vyhraj skvělé ceny. 🏅 (určeno pro hráče ve věku od 6 do 18 let)\"")
        /// Sdílej nás kamarádům
        internal static let title = L10n.tr("Localizable", "settings.field.share.title", fallback: "Sdílej nás kamarádům")
      }
      internal enum Sponsors {
        /// Partneři naší hry
        internal static let title = L10n.tr("Localizable", "settings.field.sponsors.title", fallback: "Partneři naší hry")
      }
    }
    internal enum Mail {
      /// Zpráva z aplikace od
      internal static let subject = L10n.tr("Localizable", "settings.mail.subject", fallback: "Zpráva z aplikace od")
      internal enum Footer {
        /// Pokud máte problém, prosím nemažte text níže. Slouží k rychlejšímu vyřešení problému.
        internal static let title = L10n.tr("Localizable", "settings.mail.footer.title", fallback: "Pokud máte problém, prosím nemažte text níže. Slouží k rychlejšímu vyřešení problému.")
        /// ID
        internal static let userId = L10n.tr("Localizable", "settings.mail.footer.user_id", fallback: "ID")
        /// Uživatelské jméno
        internal static let username = L10n.tr("Localizable", "settings.mail.footer.username", fallback: "Uživatelské jméno")
      }
    }
    internal enum Section {
      /// Obecné
      internal static let main = L10n.tr("Localizable", "settings.section.main", fallback: "Obecné")
      /// Osobní
      internal static let personal = L10n.tr("Localizable", "settings.section.personal", fallback: "Osobní")
    }
  }
  internal enum Stats {
    /// Pořadí: %d.
    internal static func myPosition(_ p1: Int) -> String {
      return L10n.tr("Localizable", "stats.myPosition", p1, fallback: "Pořadí: %d.")
    }
    /// Pořadí
    internal static let title = L10n.tr("Localizable", "stats.title", fallback: "Pořadí")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
