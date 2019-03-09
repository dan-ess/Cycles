//
//  Service.swift
//  Cycles
//

import Kanna
import Moya

public typealias ParameterDict = [String: Any?]

enum CycleService {
    case login(username: String, password: String)
    case cyclePorts(username: String, sessionID: String, area: CycleServiceArea)
    case cycles(username: String, sessionID: String, cyclePort: CyclePort)
    case rent(username: String, sessionID: String, cycle: Cycle)
    case cancelRental(username: String, sessionID: String)
}

extension CycleService: TargetType {
    var headers: [String : String]? {
        return [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A356 Safari/604.1"
        ]
    }
    
    var baseURL: URL {
        return URL(string: "https://tcc.docomo-cycle.jp/cycle/TYO/cs_web_main.php")!
    }
    
    var path: String {
        switch self {
        case .login, .cyclePorts, .cycles, .rent, .cancelRental:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .cyclePorts, .cycles, .rent, .cancelRental:
            return .post
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var parameters: ParameterDict {
        var parameters = ParameterDict()
        switch self {
        case .login(let username, let password):
            parameters["GarblePrevention"] = "ＰＯＳＴデータ"
            parameters["EventNo"] = "21401"
            parameters["MemberID"] = username
            parameters["Password"] = password
        case .cyclePorts(let username, let sessionID, let area):
            parameters["EventNo"] = "25706"
            parameters["SessionID"] = sessionID
            parameters["UserID"] = "TYO"
            parameters["MemberID"] = username
            parameters["GetInfoNum"] = "100"
            parameters["GetInfoTopNum"] = "1"
            parameters["MapType"] = "1"
            parameters["MapCenterLat"] = ""
            parameters["MapCenterLon"] = ""
            parameters["MapZoom"] = "13"
            parameters["EntServiceID"] = "TYO0001"
            parameters["AreaID"] = String(area.rawValue)
        case .cycles(let username, let sessionID, let cyclePort):
            parameters["EventNo"] = "25701"
            parameters["SessionID"] = sessionID
            parameters["UserID"] = "TYO"
            parameters["MemberID"] = username
            parameters["GetInfoNum"] = "40"
            parameters["GetInfoTopNum"] = "1"
            parameters["ParkingEntID"] = "TYO"
            parameters["ParkingID"] = cyclePort.parkingID
            parameters["ParkingLat"] = cyclePort.parkingLat
            parameters["ParkingLon"] = cyclePort.parkingLon
        case .rent(let username, let sessionID, let cycle):
            parameters["EventNo"] = "25901"
            parameters["SessionID"] = sessionID
            parameters["UserID"] = "TYO"
            parameters["MemberID"] = username
            parameters["CenterLat"] = cycle.centerLat
            parameters["CenterLon"] = cycle.centerLon
            parameters["CycLat"] = cycle.cycLat
            parameters["CycLon"] = cycle.cycLon
            parameters["CycleID"] = cycle.cycleID
            parameters["AttachID"] = cycle.attachID
            parameters["CycleTypeNo"] = cycle.cycleTypeNo
            parameters["CycleEntID"] = cycle.cycleEntID
        case .cancelRental(let username, let sessionID):
            parameters["EventNo"] = "27901"
            parameters["SessionID"] = sessionID
            parameters["UserID"] = "TYO"
            parameters["MemberID"] = username
        }
        return parameters
    }
    
    var extra : ParameterDict {
        var parameters = ParameterDict()
        switch self {
        case .cycles(_, _, let cyclePort):
            parameters["cyclePort"] = cyclePort
        case .rent(_, _, let cycle):
            parameters["cycle"] = cycle
        default:
            break
        }
        return parameters
    }
    
    var task: Task {
        switch self {
        case .login, .cyclePorts, .cycles, .rent, .cancelRental:
            let encodedBody = parameters.urlEncodedString()
            let data = Data(encodedBody.utf8)
            return .requestData(data)
        }
    }
    
    public var sampleData: Data {
        switch self {
        case .login("baduser", "badpass"):
            return """
            """.data(using: String.Encoding.shiftJIS)!
        case .login(_, _):
            return """
                <!DOCTYPE html>
                <html lang=\"ja\">
                <head>
                <meta charset=\"UTF-8\">
                <meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">
                <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">
                <meta name=\"description\" content=\"\">
                <meta name=\"keywords\" content=\"\">
                <meta name=\"robots\" content=\"index,follow\">
                <meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">
                <meta name=\"format-detection\" content=\"telephone=no\">
                <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/jquery.mobile.structure-1.4.5.min.css\">
                <script type=\"text/javascript\" src=\"./js/jquery.min.js\"></script>
                <script type=\"text/javascript\" src=\"./js/jquery-migrate-3.0.0.min.js\"></script>
                <script type=\"text/javascript\"><!--
                $(document).bind(\"mobileinit\",function(){
                $.mobile.page.prototype.options.keepNative = \".data-role-none, .data-role-none *\";
                $.mobile.ajaxEnabled = false;
                $.mobile.pushStateEnabled = false;
                });
                // -->
                </script>
                <script type=\"text/javascript\" src=\"./js/jquery.mobile-1.4.5.min.js\"></script>
                <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/import_sp_tab_pc.css\">
                <title>自転車シェアリング広域実験</title>
                <script>
                </script>
                </head>
                <body id=\"wrapper_jqm\" class=\"data-role-none\">
                <header>
                <div class=\"hdr clearfix\">
                <img class=\"hdr_logo_l\" src=\"./img/hdr_logo01.png\">
                </div>
                </header>
                <script type=\"text/javascript\">
                </script>
                <div class=\"main\">
                <div class=\"tittle\">
                <div class=\"main_inner_wide_tittle\">
                <h1 class=\"tittle_h1\">マイページ/My page</h1>
                </div>
                </div>
                <div class=\"main_inner_wide\">
                <div class=\"user_inf sp_view\">
                B.中央/Chuo
                <br>
                ようこそ username さん
                <br>
                Welcome User ID：userID
                <br>
                前回のログイン日時/The last login date ：2019/01/01 00:00:00
                </div>
                <div class=\"user_inf pc_view\">
                B.中央/Chuo
                <br>
                ようこそ username さん
                /Welcome User ID：userID
                <br>
                前回のログイン日時/The last login date ：2019/01/01 00:00:00
                </div>
                <hr class=\"m0\">
                <p class=\"err_text\">
                長期間パスワードが変更されていません。/The password has not been changed for a long period of time.</p>
                <div class=\"sp_view\">
                <h2 class=\"cpt_h2\">サービスを利用する/Service</h2>
                <div class=\"mpt_inner\">
                <img class=\"mpt_logo\" src=\"./img/mpt_logo1.gif\">
                <h3 class=\"mpt_h3\">自転車を借りる / Use a bike</h3>
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"from_port_sp\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21614\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
                <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
                <input type=\"hidden\" name=\"MapType\" value=\"1\">
                <input type=\"hidden\" name=\"MapCenterLat\" value=\"\">
                <input type=\"hidden\" name=\"MapCenterLon\" value=\"\">
                <input type=\"hidden\" name=\"MapZoom\" value=\"13\">
                <input type=\"hidden\" name=\"EntServiceID\" value=\"TYO0001\">
                <input type=\"hidden\" name=\"AreaID\" value=\"2\">
                <input type=\"hidden\" name=\"Location\" value=\"\">
                <div>
                <a class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:from_port_sp.submit();\">駐輪場から選ぶ/Choose from port</a>
                </div>
                </form>
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"select_cycle_sp\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21611\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"DiscriminationNo\" value=\"\">
                <div>
                <a class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon mt5\" href=\"javascript:select_cycle_sp.submit();\">自転車を指定する/Select a bike</a>
                </div>
                </form>
                </div>
                </div>
                <div class=\"pc_view\">
                <h2 class=\"cpt_h2\">サービスを利用する/Service</h2>
                <div class=\"mpt_inner\">
                <h3 class=\"mpt_h3\">自転車を借りる：Use a bike</h3>
                <img class=\"mpt_logo\" src=\"./img/mpt_logo1.gif\">
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"from_port_tab\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21614\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
                <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
                <input type=\"hidden\" name=\"MapType\" value=\"1\">
                <input type=\"hidden\" name=\"MapCenterLat\" value=\"\">
                <input type=\"hidden\" name=\"MapCenterLon\" value=\"\">
                <input type=\"hidden\" name=\"MapZoom\" value=\"13\">
                <input type=\"hidden\" name=\"EntServiceID\" value=\"TYO0001\">
                <input type=\"hidden\" name=\"AreaID\" value=\"2\">
                <input type=\"hidden\" name=\"Location\" value=\"\">
                <div>
                <a class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:from_port_tab.submit();\">駐輪場から選ぶ/Choose from port</a>
                </div>
                </form>
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"select_cycle_tab\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21611\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"DiscriminationNo\" value=\"\">
                <div>
                <a class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon mt5\" href=\"javascript:select_cycle_tab.submit();\">自転車を指定する/Select a bike</a>
                </div>
                </form>
                </div>
                </div>
                <div class=\"sp_view\">
                <h2 class=\"cpt_h2\">各種情報/Various information</h2>
                <div class=\"mpt_inner\">
                <img class=\"mpt_logo\" src=\"./img/mpt_logo3.gif\">
                <h3 class=\"mpt_h3\">ご利用明細 / Usage details</h3>
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"billing_amount_sp\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21605\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"StartYear\" value=\"2019\">
                <input type=\"hidden\" name=\"StartMonth\" value=\"03\">
                <div>
                <a id=\"sp_bill\" class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableAnchorSp(); billing_amount_sp.submit();\">請求予定額/Billing</a>
                </div>
                </form>
                </div>
                <h2 class=\"cpt_h2\">会員情報/Membership information</h2>
                <div class=\"mpt_inner\">
                <img class=\"mpt_logo\" src=\"./img/mpt_logo4.gif\">
                <h3 class=\"mpt_h3\">会員情報 / Membership information</h3>
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"conf_chg_sp\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21606\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <div>
                <a class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:conf_chg_sp.submit();\">設定・変更/Correction</a>
                </div>
                </form>
                </div>
                </div>
                <div class=\"pc_view\">
                <div class=\"mpt_inner_box\">
                <div class=\"mpt_inner_left\">
                <h2 class=\"cpt_h2\">各種情報/Various information</h2>
                <div class=\"mpt_inner\">
                <h3 class=\"mpt_h3\">ご利用明細：Usage details</h3>
                <img class=\"mpt_logo\" src=\"./img/mpt_logo3.gif\">
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"billing_amount_tab\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21605\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"StartYear\" value=\"2019\">
                <input type=\"hidden\" name=\"StartMonth\" value=\"03\">
                <div>
                <a id=\"pc_bill\" class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableAnchorPc(); billing_amount_tab.submit();\">請求予定額/Billing</a>
                </div>
                </form>
                </div>
                </div>
                <div class=\"mpt_inner_right\">
                <h2 class=\"cpt_h2\">会員情報/Membership information</h2>
                <div class=\"mpt_inner\">
                <h3 class=\"mpt_h3\">会員情報：Membership information</h3>
                <img class=\"mpt_logo\" src=\"./img/mpt_logo4.gif\">
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"conf_chg_tab\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21606\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <div>
                <a class=\"mpt_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:conf_chg_tab.submit();\">設定・変更/Correction</a>
                </div>
                </form>
                </div>
                </div>
                </div>
                </div>
                <div class=\"mpt_inner_box\">
                <div class=\"mpt_inner_logout\">
                <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\">
                <input type=\"hidden\" name=\"EventNo\" value=\"21607\">
                <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
                <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
                <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
                <input type=\"hidden\" name=\"MemAreaID\" value=\"2\">
                <input type=\"submit\" value=\"ログアウトする/LOG OUT\" class=\"button_submit prevaction\">
                </form>
                </div>
                </div>
                </div>
                </div>
                <script>
                </script>
                </body>
                </html>
                """.data(using: String.Encoding.shiftJIS)!
            
        case .cyclePorts(_, _, _):
            return """
            <!DOCTYPE html>
            <html lang=\"ja\">
            <head>
            <meta charset=\"UTF-8\">
            <meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">
            <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">
            <meta name=\"description\" content=\"\">
            <meta name=\"keywords\" content=\"\">
            <meta name=\"robots\" content=\"index,follow\">
            <meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">
            <meta name=\"format-detection\" content=\"telephone=no\">
            <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/jquery.mobile.structure-1.4.5.min.css\">
            <script type=\"text/javascript\" src=\"./js/jquery.min.js\"></script>
            <script type=\"text/javascript\" src=\"./js/jquery-migrate-3.0.0.min.js\"></script>
            <script type=\"text/javascript\"><!--
            // -->
            </script>
            <script type=\"text/javascript\" src=\"./js/jquery.mobile-1.4.5.min.js\"></script>
            <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/import_sp_tab_pc.css\">
            <title>自転車シェアリング広域実験</title>
            <script>
            </script>
            </head>
            <body id=\"wrapper_jqm\" class=\"data-role-none\">
            <header>
            <div class=\"hdr clearfix\">
            <img class=\"hdr_logo_l\" src=\"./img/hdr_logo01.png\">
            </div>
            </header>
            <script type=\"text/javascript\">
            </script>
            <div class=\"main\">
            <div class=\"tittle\">
            <div class=\"main_inner_wide_tittle\">
            <h1 class=\"tittle_h1\">駐輪場から選ぶ/Choose from port</h1>
            </div>
            </div>
            <div class=\"main_inner_wide\">
            <div class=\"main_inner_wide_box\">
            <div class=\"main_inner_wide_right\">
            </div>
            <div class=\"main_inner_wide_left\">
            <h2 class=\"cpt_h2\">地域を選ぶ/Choose the Area</h2>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sel_area\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25706\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"MapType\" value=\"1\">
            
            <input type=\"hidden\" name=\"MapCenterLat\" value=\"\">
            <input type=\"hidden\" name=\"MapCenterLon\" value=\"\">
            <input type=\"hidden\" name=\"MapZoom\" value=\"13\">
            <input type=\"hidden\" name=\"EntServiceID\" value=\"TYO0001\">
            <input type=\"hidden\" name=\"Location\" value=\"\">
            <select name=\"AreaID\" id=\"AreaID\" onChange=\"sel_area_send()\">
            <option value=\"1\">A.千代田/Chiyoda
            <option value=\"2\" selected>B.中央/Chuo
            <option value=\"3\">C.港/Minato
            <option value=\"5\">D.新宿/Shinjuku
            <option value=\"6\">E.文京/Bunkyo
            <option value=\"4\">H.江東/Koto
            <option value=\"10\">I.品川/Shinagawa
            <option value=\"12\">J.目黒/Meguro
            <option value=\"7\">K.大田/Ota
            <option value=\"8\">M.渋谷/Shibuya
            </select>
            </form>
            <h2 class=\"cpt_h2\">場所を選ぶ/Choose the Place</h2>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sel_location\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25707\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"MapType\" value=\"1\">
            <input type=\"hidden\" name=\"MapCenterLat\" value=\"\">
            <input type=\"hidden\" name=\"MapCenterLon\" value=\"\">
            <input type=\"hidden\" name=\"MapZoom\" value=\"13\">
            <input type=\"hidden\" name=\"EntServiceID\" value=\"TYO0001\">
            <input type=\"hidden\" name=\"AreaID\" value=\"2\">
            <select name=\"Location\" id=\"Location\" onChange=\"sel_location_send()\">
            <option value=\"\" selected>すべて/All
            <option value=\"京橋/Kyobashi\">京橋/Kyobashi
            <option value=\"日本橋/Nihonbashi\">日本橋/Nihonbashi
            <option value=\"晴海・月島/Harumi・Tsukishima\">晴海・月島/Harumi・Tsukishima
            <option value=\"銀座・築地/Ginza・Tsukiji\">銀座・築地/Ginza・Tsukiji
            </select>
            </form>
            </div>
            </div>
            <br>
            検索結果　55件中　1～55件表示/ 1-55 of 55 results<br>
            <div class=\"table_name\">ポート一覧/Port list</div>
            <div class=\"sp_view\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sp_10047\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10047\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.691058\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.777915\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/00010047.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:sp_10047.submit();\">B1-01.十思公園<br>B1-01.Jisshi Park<br>12台</a>
            </div>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sp_10048\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10048\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.686864\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.778957\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/00010048.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:sp_10048.submit();\">B1-02.堀留児童公園（西側）<br>B1-02.Horidome Children&#039;s Park(West side)<br>3台</a>
            </div>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sp_10260\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10260\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.656609\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.775043\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/noimage.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:sp_10260.submit();\">メンテナンスセンター（06）<br>Maintenance Center(06)<br>0台</a>
            </div>
            </div>
            </form>
            </div>
            <div class=\"pc_view\">
            <div class=\"main_inner_wide_box\">
            <div class=\"main_inner_wide_left_list\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_10047\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10047\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.691058\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.777915\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/00010047.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:tab_10047.submit();\">B1-01.十思公園<br>B1-01.Jisshi Park<br>12台</a>
            </div>
            </div>
            </form>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_10260\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10260\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.656609\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.775043\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/noimage.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:tab_10260.submit();\">メンテナンスセンター（06）<br>Maintenance Center(06)<br>0台</a>
            </div>
            </div>
            </form>
            </div>
            <div class=\"main_inner_wide_right_list\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_10048\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10048\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.686864\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.778957\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/00010048.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:tab_10048.submit();\">B1-02.堀留児童公園（西側）<br>B1-02.Horidome Children&#039;s Park(West side)<br>3台</a>
            </div>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_10050\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10050\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.694164\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.787057\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/00010050.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:tab_10050.submit();\">B1-04.産業会館<br>B1-04.Industrial Hall<br>19台</a>
            </div>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_10052\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25701\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"GetInfoNum\" value=\"20\">
            <input type=\"hidden\" name=\"GetInfoTopNum\" value=\"1\">
            <input type=\"hidden\" name=\"ParkingEntID\" value=\"TYO\">
            <input type=\"hidden\" name=\"ParkingID\" value=\"10052\">
            <input type=\"hidden\" name=\"ParkingLat\" value=\"35.687624\">
            <input type=\"hidden\" name=\"ParkingLon\" value=\"139.777125\">
            <div class=\"port_list_btn\">
            <img src=\"../park_img/00010052.jpg\"  class=\"port_list_btn_img\"><div class=\"port_list_btn_inner\">
            <a class=\"port_list_btn_inner ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:tab_10052.submit();\">B1-06.伊場仙ビル<br>B1-06.IBASEN<br>1台</a>
            </div>
            </div>
            </form>
            </div>
            </div>
            </div>
            <div class=\"main_inner_wide_box mt20\">
            <div class=\"main_inner_wide_left\">
            </div>
            <div class=\"main_inner_wide_right\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25704\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"submit\" value=\"トップに戻る/HOME\" class=\"button_submit prevaction\">
            </form>
            </div>
            </div>
            </div>
            </div>
            </body>
            </html>
            """.data(using: String.Encoding.shiftJIS)!
        case .cycles(_, _, _):
            return """
            <!DOCTYPE html>
            <html lang=\"ja\">
            <head>
            <meta charset=\"UTF-8\">
            <meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">
            <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">
            <meta name=\"description\" content=\"\">
            <meta name=\"keywords\" content=\"\">
            <meta name=\"robots\" content=\"index,follow\">
            <meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">
            <meta name=\"format-detection\" content=\"telephone=no\">
            <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/jquery.mobile.structure-1.4.5.min.css\">
            <script type=\"text/javascript\" src=\"./js/jquery.min.js\"></script>
            <script type=\"text/javascript\" src=\"./js/jquery-migrate-3.0.0.min.js\"></script>
            <script type=\"text/javascript\">
            </script>
            <script type=\"text/javascript\" src=\"./js/jquery.mobile-1.4.5.min.js\"></script>
            <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/import_sp_tab_pc.css\">
            <title>自転車シェアリング広域実験</title>
            <script>
            </script>
            </head>
            <body id=\"wrapper_jqm\" class=\"data-role-none\">
            <header>
            <div class=\"hdr clearfix\">
            <img class=\"hdr_logo_l\" src=\"./img/hdr_logo01.png\">
            </div>
            </header>
            <script type=\"text/javascript\">
            </script>
            <div class=\"main\">
            <div class=\"tittle\">
            <div class=\"main_inner_wide_tittle\">
            <h1 class=\"tittle_h1\">自転車を指定する/Select a bike</h1>
            </div>
            </div>
            <div class=\"main_inner_wide\">
            <h2 class=\"cpt_h2\">自転車を指定する/Select a bike</h2>
            <div class=\"park_info_box\">
            <div class=\"park_info_img\">
            <img src=\"../park_img/00010214.jpg\"  class=\"park_img\"></div>
            <div class=\"park_info_inner\">
            <div class=\"park_info_inner_left\">
            ■ポート名/Port name<br>
            　　B2-10.東京ダイヤビルディング（北側）<br>
            　　B2-10.Norh Side of Tokyo Dia Building
            </div>
            <div class=\"park_info_inner_right\">
            ■利用可能時間/Available time<br>
            　　24時間営業<br>
            　　(24/7)
            </div>
            </div>
            </div>
            <hr class=\"mt10 mb10\">
            検索結果　3件中　1～3件表示/ 1-3 of 3 results<br>
            <div class=\"table_name\">自転車一覧/Bike list</div>
            <div class=\"sp_view\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sp_TYO_617\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"CenterLat\" value=\"35.675702\">
            <input type=\"hidden\" name=\"CenterLon\" value=\"139.785229\">
            <input type=\"hidden\" name=\"CycLat\" value=\"35.675955\">
            <input type=\"hidden\" name=\"CycLon\" value=\"139.784585\">
            <input type=\"hidden\" name=\"CycleID\" value=\"617\">
            <input type=\"hidden\" name=\"AttachID\" value=\"10582\">
            <input type=\"hidden\" name=\"CycleTypeNo\" value=\"4\">
            <input type=\"hidden\" name=\"CycleEntID\" value=\"TYO\">
            <div class=\"cycle_list_btn\">
            <a id=\"cycBtnSp_0\" class=\"cycle_list_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableSp(3); sp_TYO_617.submit();\">CYD0202</a>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sp_TYO_201\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"CenterLat\" value=\"35.675702\">
            <input type=\"hidden\" name=\"CenterLon\" value=\"139.785229\">
            <input type=\"hidden\" name=\"CycLat\" value=\"35.675845\">
            <input type=\"hidden\" name=\"CycLon\" value=\"139.784920\">
            <input type=\"hidden\" name=\"CycleID\" value=\"201\">
            <input type=\"hidden\" name=\"AttachID\" value=\"13337\">
            <input type=\"hidden\" name=\"CycleTypeNo\" value=\"3\">
            <input type=\"hidden\" name=\"CycleEntID\" value=\"TYO\">
            <div class=\"cycle_list_btn\">
            <a id=\"cycBtnSp_1\" class=\"cycle_list_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableSp(3); sp_TYO_201.submit();\">MNT0349</a>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"sp_TYO_5031\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"CenterLat\" value=\"35.675702\">
            <input type=\"hidden\" name=\"CenterLon\" value=\"139.785229\">
            <input type=\"hidden\" name=\"CycLat\" value=\"35.675970\">
            <input type=\"hidden\" name=\"CycLon\" value=\"139.785347\">
            <input type=\"hidden\" name=\"CycleID\" value=\"5031\">
            <input type=\"hidden\" name=\"AttachID\" value=\"16636\">
            <input type=\"hidden\" name=\"CycleTypeNo\" value=\"6\">
            <input type=\"hidden\" name=\"CycleEntID\" value=\"TYO\">
            <div class=\"cycle_list_btn\">
            <a id=\"cycBtnSp_2\" class=\"cycle_list_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableSp(3); sp_TYO_5031.submit();\">MNT1160</a>
            </div>
            </form>
            </div>
            <div class=\"pc_view\">
            <div class=\"main_inner_wide_box\">
            <div class=\"main_inner_wide_left_list\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_TYO_617\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"CenterLat\" value=\"35.675702\">
            <input type=\"hidden\" name=\"CenterLon\" value=\"139.785229\">
            <input type=\"hidden\" name=\"CycLat\" value=\"35.675955\">
            <input type=\"hidden\" name=\"CycLon\" value=\"139.784585\">
            <input type=\"hidden\" name=\"CycleID\" value=\"617\">
            <input type=\"hidden\" name=\"AttachID\" value=\"10582\">
            <input type=\"hidden\" name=\"CycleTypeNo\" value=\"4\">
            <input type=\"hidden\" name=\"CycleEntID\" value=\"TYO\">
            <div class=\"cycle_list_btn\">
            <a id=\"cycBtnTab_0\" class=\"cycle_list_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableTab(3); tab_TYO_617.submit();\">CYD0202</a>
            </div>
            </form>
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_TYO_5031\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"CenterLat\" value=\"35.675702\">
            <input type=\"hidden\" name=\"CenterLon\" value=\"139.785229\">
            <input type=\"hidden\" name=\"CycLat\" value=\"35.675970\">
            <input type=\"hidden\" name=\"CycLon\" value=\"139.785347\">
            <input type=\"hidden\" name=\"CycleID\" value=\"5031\">
            <input type=\"hidden\" name=\"AttachID\" value=\"16636\">
            <input type=\"hidden\" name=\"CycleTypeNo\" value=\"6\">
            <input type=\"hidden\" name=\"CycleEntID\" value=\"TYO\">
            <div class=\"cycle_list_btn\">
            <a id=\"cycBtnTab_2\" class=\"cycle_list_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableTab(3); tab_TYO_5031.submit();\">MNT1160</a>
            </div>
            </form>
            </div>
            <div class=\"main_inner_wide_right_list\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\" name=\"tab_TYO_201\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"hidden\" name=\"CenterLat\" value=\"35.675702\">
            <input type=\"hidden\" name=\"CenterLon\" value=\"139.785229\">
            <input type=\"hidden\" name=\"CycLat\" value=\"35.675845\">
            <input type=\"hidden\" name=\"CycLon\" value=\"139.784920\">
            <input type=\"hidden\" name=\"CycleID\" value=\"201\">
            <input type=\"hidden\" name=\"AttachID\" value=\"13337\">
            <input type=\"hidden\" name=\"CycleTypeNo\" value=\"3\">
            <input type=\"hidden\" name=\"CycleEntID\" value=\"TYO\">
            <div class=\"cycle_list_btn\">
            <a id=\"cycBtnTab_1\" class=\"cycle_list_btn ui-btn ui-icon-redcarat ui-btn-icon-right ui-nodisc-icon\" href=\"javascript:doubleDisableTab(3); tab_TYO_201.submit();\">MNT0349</a>
            </div>
            </form>
            </div>
            </div>
            </div>
            <div class=\"main_inner_wide_box mt20\">
            <div class=\"main_inner_wide_left\">
            </div>
            <div class=\"main_inner_wide_right\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\">
            <input type=\"hidden\" name=\"EventNo\" value=\"25904\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"submit\" value=\"トップに戻る/HOME\" class=\"button_submit prevaction\">
            </form>
            </div>
            </div>
            </div>
            </div>
            </body>
            </html>
            """.data(using: String.Encoding.shiftJIS)!
        case .rent(_, _, _):
            return """
            <!DOCTYPE html>
            <html lang=\"ja\">
            <head>
            <meta charset=\"UTF-8\">
            <meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">
            <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">
            <meta name=\"description\" content=\"\">
            <meta name=\"keywords\" content=\"\">
            <meta name=\"robots\" content=\"index,follow\">
            <meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0\">
            <meta name=\"format-detection\" content=\"telephone=no\">
            <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/import_sp_tab_pc.css\">
            <title>自転車シェアリング広域実験</title>
            <script>
            </script>
            </head>
            <body id=\"wrapper\">
            <header>
            <div class=\"hdr clearfix\">
            <img class=\"hdr_logo_l\" src=\"./img/hdr_logo01.png\">
            </div>
            </header>
            <div class=\"main\">
            <div class=\"tittle\">
            <div class=\"main_inner_wide_tittle\">
            <h1 class=\"tittle_h1\">利用予約申込を受け付けました/[Complete] Use a bike</h1>
            </div>
            </div>
            <div class=\"main_inner_wide\">
            <br>
            20分以内に自転車の操作機から利用開始操作を実施して下さい。/Please use a bike within 20 minutes.<br>
            <br>
            自転車番号/Bike No.<br>
            　　CYD0202<br>
            <br>
            開錠パスコード/Passcode<br>
            　　
            <font size=\"5\" color=\"red\">
            9834
            </font>
            <br>
            <br>
            登録されたメールアドレスにこのパスコードを記載したメールを送信しました。/Passcode has been sent to the email address you entered. <br>
            <br>
            <div class=\"main_inner_wide_box mt20\">
            <div class=\"main_inner_wide_left\">
            <form method=\"POST\" action=\"/cycle/TYO/cs_web_main.php\">
            <input type=\"hidden\" name=\"EventNo\" value=\"21901\">
            <input type=\"hidden\" name=\"SessionID\" value=\"TYOuserIDsessionID1111\">
            <input type=\"hidden\" name=\"UserID\" value=\"TYO\">
            <input type=\"hidden\" name=\"MemberID\" value=\"userID\">
            <input type=\"submit\" value=\"トップに戻る/HOME\" class=\"button_submit prevaction\">
            </form>
            </div>
            </div>
            </div>
            </div>
            </body>
            </html>
            """.data(using: String.Encoding.shiftJIS)!
        case .cancelRental(_, _):
            return Data()
        }
    }
}


