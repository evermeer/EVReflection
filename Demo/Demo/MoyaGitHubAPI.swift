import Foundation
import Moya

// MARK: - Provider setup (One without and one with Rx support)
let GitHubMoyaProvider = MoyaProvider<GitHub>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

let GitHubRxMoyaProvider = RxMoyaProvider<GitHub>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data //fallback to original data if it cant be serialized
    }
}


// MARK: - Provider support

public enum GitHub {
    case zen
    case userProfile(String)
    case userRepositories(String)
    case repo(String)
    case issues(String)
    case xml
    case nestedArray
}

extension GitHub: TargetType {
    public var headers: [String : String]? {
        return nil
    }
    
    
    public var baseURL: URL {
        switch self {
        case .xml:
            return URL(string: "http://raw.githubusercontent.com/evermeer/AlamofireXmlToObjects/master/AlamofireXmlToObjectsTests")!
        case .nestedArray:
            return URL(string: "http://raw.githubusercontent.com/evermeer/EVReflection/UnitTests/MoyaTests")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }
    
    public var path: String {
        switch self {
        case .zen:
            return "/zen"
        case .userProfile(let name):
            return "/users/\(name.urlEscapedString)"
        case .userRepositories(let name):
            return "/users/\(name.urlEscapedString)/repos"
        case .repo(let name):
            return "/repos/\(name)"
        case .issues(let repositoryName):
            return "/repos/\(repositoryName)/issues"
        case .xml:
            return "/sample_xml"
        case .nestedArray:
            return "/nestedArrayData_json"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .userRepositories(_):
            return ["sort": "pushed"]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return  URLEncoding.queryString
    }

    public var task: Task {
        return .requestPlain
    }
    
    public var sampleData: Data {
        switch self {
        case .zen:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        case .userProfile(let name):
            return "{\"login\": \"\(name)\", \"id\": 100}".data(using: String.Encoding.utf8)!
        case .userRepositories(_):
            return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
        case .repo(_):
            return "{\"id\": \"1\", \"language\": \"Swift\", \"url\": \"https://api.github.com/repos/mjacko/Router\", \"name\": \"Router\"}".data(using: .utf8)!
        case .issues(_):
            return "{\"id\": 132942471, \"number\": 405, \"title\": \"Updates example with fix to String extension by changing to Optional\", \"body\": \"Fix it pls.\"}".data(using: .utf8)!
        case .xml:
            return "<wheather><location>Toronto, Canada</location></wheather>".data(using: String.Encoding.utf8)!
        case .nestedArray:
            return "[[{\"id\":1},{\"id\":2}]]".data(using: String.Encoding.utf8)!
        }
    }
}

// MARK: - Helper extensions

private extension String {
    var urlEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

