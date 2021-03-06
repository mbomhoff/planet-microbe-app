module Config exposing (..)



---- Backend REST API ----


apiBaseUrl : String
apiBaseUrl =
    "http://localhost:3020"



---- Misc ----


alertBannerText : Maybe String
alertBannerText =
    Nothing


maintenanceMode : Bool
maintenanceMode =
    False


googleAnalyticsTrackingId : String
googleAnalyticsTrackingId =
    ""


dataCommonsUrl : String
dataCommonsUrl =
    "http://datacommons.cyverse.org/browse"


discoveryEnvironmentUrl : String
discoveryEnvironmentUrl =
    "https://de.cyverse.org/de/?type=data&folder="


sraUrl : String
sraUrl =
    "https://www.ncbi.nlm.nih.gov/sra/?term="


taxonomyUrl : String
taxonomyUrl =
    "https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id="



---- Agave API ----


agaveBaseUrl : String
agaveBaseUrl =
    "https://agave.iplantc.org"


-- OAuth2 Configuration
agaveOAuthClientId : String
agaveOAuthClientId =
    ""


agaveRedirectUrl : String
agaveRedirectUrl =
    ""


-- Remove these admin users from Share view in File Browser
filteredUsers : List String
filteredUsers =
    [ "dooley", "vaughn", "rodsadmin", "jstubbs", "jfonner", "eriksf", "QuickShare"
    , "admin2", "admin_proxy", "agave", "bisque-adm", "de-irods", "has_admin", "ibp-proxy"
    , "ipc_admin", "ipcservices", "proxy-de-tools", "uk_admin", "uportal_admin2", "terraref_admin"
    , "avra_admin", "tacc_admin"
    ]



---- Plan B ----


-- Base URL
planbBaseUrl : String
planbBaseUrl =
    "https://www.imicrobe.us/plan-b"