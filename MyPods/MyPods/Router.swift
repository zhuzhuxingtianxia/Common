


//
//  Router.swift
//  Tuhu
//
//  Created by 丁帅 on 16/9/5.
//  Copyright © 2016年 Tuhu. All rights reserved.
//

/*
import UIKit

class Router: NSObject {
    
    // MARK: 外部方法
    /// 外部调用
    @discardableResult
    class func to(_ url: URL) -> Bool {
        let (_target, formatteParams, params) = parseURL(url)
        if let target = _target {
            return to(target, params: formatteParams, options: getRouteOptions(params), style: getRouteStyle(params))
        }
        return false
    }
    
    class func canRouter(_ url: URL?) -> Bool {
        if let url = url {
            return checkRouter(_:url)
        }
        return false
    }
    
    // MARK: 内部方法
    ///内部调用
    @discardableResult
    class func to(_ path:String, formatteParams:[String : Any]? = nil, options: THRouteOption = []) -> Bool {
        guard let target = getTarget(path, keyParams:formatteParams) else {
            return false
        }
        // 根据 目标类型的 map 修正参数列表
        var reformP = formatteParams
        if let map = target.cls.routeParamMap?() {
            reformP = formatteParams?.map(map)
        }
        return to(target, params: reformP, options: options, style: nil)
    }
    
    class func getVCFrom(url:URL) -> UIViewController? {
        let (target, formatteParams, params) = parseURL(url)
        
        if let _target = target {
            let style = getRouteStyle(params) ?? _target.style
            let option = _target.option.union(getRouteOptions(params))
            
            // 暂只支持获取push并且不需要车型且不需要登录的控制器
            guard style == .push && mapCarLevel(option) == nil && !option.contains(.login) else {
                return nil
            }
            
            var vc = _target.cls.routeViewController?(withURI: _target.uri, params: formatteParams)
            if vc == nil {
                // 检测目标类型是否是控制器，若不是， 直接返回
                guard let vcClass = _target.cls as? UIViewController.Type else { return nil }
                vc = creatViewController(vcClass, params: formatteParams)
            }
            return vc
        }
        else {
            return nil
        }
    }
}

// MARK: router 实现
extension Router {
    fileprivate class func checkRouter(_ url: URL) -> Bool {
        let fixedURL = fixURL(url) //修正URL
        // 检测URI有效性
        let URI = fixedURL.path
        let filter = mapping.filter ({ return $0.uri == URI })
        guard filter.count > 0 else {
            return false
        }
        return true
    }
    
    fileprivate class func parseURL(_ URL: URL) -> (RouteElemet?, [String: Any]?, [String: String]?) {
        let fixedURL = fixURL(URL) //修正URL
        // 检测URI有效性
        let URI = fixedURL.path
        // 解析参数
        var params = fixedURL.query?.formURLParams()
        // 获取 Route 模型
        guard let target = getTarget(URI, keyParams: params) else { return (nil, nil, nil) }
        // 根据 目标类型的 map 修正参数列表
        if let map = target.cls.routeParamMap?() {
            params = params?.map(map)
        }
        
        // 将参数列表中的字符串值转换为json对象
        var formatteParams = params?.reduce([String:Any]()) {
            let k = $1.key
            let v = $1.value
            guard let valueData = v.data(using: String.Encoding.utf8) else { return $0 + [k : v] }
            guard let valueObjc = try? JSONSerialization.jsonObject(with: valueData, options: .mutableContainers) else { return $0 + [k : v] }
            return $0 + [k : valueObjc]
        }
        
        // 将参数列表中的对象集合序列化
        if let _param = formatteParams {
            formatteParams = MMUtils.formatterJsonData(toModel: _param) as? [String: Any]
        }
        
        // 获取导航栏颜色
        if let colors = params?["color"]?.components(separatedBy: "|"), colors.count == 2 && colors.reduce(true, { $0 && $1.hasPrefix("#") }) {
            let colorValues = colors.map{ UIColor(hexString: $0) }
            formatteParams? = [:]
            formatteParams?["navTintColor"] = colorValues[0]
            formatteParams?["navBarColor"] = colorValues[1]
        }
        
        // 设置导航栏隐藏
        if let navHidden = params?["navHidden"] {
            formatteParams? = [:]
            formatteParams?["navigationBarHidden"] = Bool(navHidden)
        }
        return (target, formatteParams, params)
    }
    
    //修正URL:截取蓄电池链接,转成Router
    fileprivate class func fixURL(_ URL: Foundation.URL) -> Foundation.URL {
        let urlStr = URL.absoluteString
        if THCommonUtils.shareInstance().checkBatteryUrl(urlStr) {
            return Foundation.URL(string: "tuhu:/battery")!
        } else if let url = URL.query?.formURLParams()["url"], URL.path == "/webView", THCommonUtils.shareInstance().checkBatteryUrl(url) {
            return Foundation.URL(string: "tuhu:/battery")!
        }
        return URL
    }
    
    fileprivate class func to(_ target:RouteElemet, params: [String: Any]?, options: THRouteOption, style: THRouteStyle?) -> Bool {
        let URI = target.uri
        
        let style = style ?? target.style
        let option = target.option.union(options)
        // 获取当前的控制器
        guard let currentVC = MMUtils.getCurrentTopViewController() else { return false }
        
        // 跳转封装
        let segue: () -> Void = {
            switch style {
            case .special, .tab:
                // 特殊跳转的处理
                target.cls.specialRoute?(withURI: URI, params: params, style: style, option: option)
            case .push:
                // 获取目标Class
                var vc = target.cls.routeViewController?(withURI: URI, params: params)
                if vc == nil {
                    // 检测目标类型是否是控制器，若不是， 直接返回
                    guard let vcClass = target.cls as? UIViewController.Type else { return }
                    vc = creatViewController(vcClass, params: params)
                }
                currentVC.navigationController?.pushViewController(vc!, animated: true)
            case .present:
                // 获取目标Class
                var vc = target.cls.routeViewController?(withURI: URI, params: params)
                if vc == nil {
                    // 检测目标类型是否是控制器，若不是， 直接返回
                    guard let vcClass = target.cls as? UIViewController.Type else { return }
                    vc = creatViewController(vcClass, params: params)
                }
                if let nav = vc as? UINavigationController {
                    currentVC.present(nav, animated: true, completion: nil)
                } else if let vc = vc {
                    currentVC.present(TNNavigationController(rootViewController: vc), animated: true, completion: nil)
                }
            }
        }
        
        // 方法修正
        let final: () -> Void
        // 车型参数检查
        if let level = mapCarLevel(option) {
            final = { THCommonUtils.shareInstance().check(level: level, fromVC: currentVC) { _ in segue() } }
        } else {
            final = segue
        }
        // 登录检查
        if option.contains(.login) {
            THCommonUtils.shareInstance().checkLoginWithCompletion(from: currentVC, completion: final)
        } else {
            final()
        }
        return true
    }
    
}

// MARK: - 工具方法
extension Router {
    /// 通过 KVC 创建控制器的方法
    fileprivate class func creatViewController(_ cls: UIViewController.Type, params: [String : Any]?) -> UIViewController {
        let vc = cls.init()
        if  let params = params {
            MMUtils.setValuesWith(params, for: vc)
        }
        return vc
    }
    
    /// 解析外部检查参数
    fileprivate class func getRouteOptions(_ params: [String : String]?) -> THRouteOption {
        var result = THRouteOption()
        if params?["requireUser"] != nil {
            result.formUnion(.login)
        }
        if params?["requireCarLevel2"] != nil {
            result.formUnion(.carBase)
        }
        if params?["requireCarLevel4"] != nil {
            result.formUnion(.carFull)
        }
        if params?["requireCarLevel5"] != nil {
            result.formUnion(.carFullWithTID)
        }
        if params?["requireTireSpec"] != nil {
            result.formUnion(.carTire)
        }
        if params?["requireWheelRimSize"] != nil {
            result.formUnion(.carWheel)
        }
        return result
    }
    
    fileprivate class func getRouteStyle(_ params: [String : String]?) -> THRouteStyle? {
        guard let str = params?["animation"] else { return nil }
        switch str {
        case "DownToUp":
            return .present
        case "RightToLeft", "LeftToRight":
            return .push
        default:
            return nil
        }
    }
    
    fileprivate class func mapCarLevel(_ option: THRouteOption) -> THCarLevel? {
        var level: THCarLevel? = nil
        if option.contains(.carBase) {
            level = .base
        }
        if option.contains(.carFull) {
            level?.formUnion(.full)
        }
        if option.contains(.carFullWithTID) {
            level?.formUnion(.TID)
        }
        if  option.contains(.carTire) {
            level?.formUnion(.tire)
        }
        if option.contains(.carWheel) {
            level?.formUnion(.wheel)
        }
        return level
    }
}

// MARK: - 注册相关
extension Router {
    // Route模型，代表注册的每一个类型
    fileprivate struct RouteElemet {
        let uri: String // 注册的URL Path
        let cls: THRouteSupport.Type
        let style: THRouteStyle
        let option: THRouteOption
        let check: ([String : Any]?) -> Bool
    }
    
    /// 保存各个控制器类型注册的Route模型
    fileprivate static var mapping: [RouteElemet] = []
    
    /// 根据URI和关键参数获取Route模型
    fileprivate class func getTarget(_ uri: String, keyParams: [String : Any]?) -> RouteElemet? {
        return mapping.filter {
            guard $0.uri == uri else { return false }
            return $0.check(keyParams)
            }.first
    }
    
    /// 注册类型的URI、Style、Option、检查闭包
    dynamic class func register(_ cls: THRouteSupport.Type, uri: String, style: THRouteStyle = .push, option: THRouteOption = THRouteOption(), check: @escaping ([String : Any]?) -> Bool = { _ in true}) {
        mapping.append(RouteElemet(uri: uri, cls: cls, style: style, option: option, check: check))
    }
    
    dynamic class func register(_ cls: THRouteSupport.Type, uri: String, style: THRouteStyle = .push, option: THRouteOption = THRouteOption())  {
        mapping.append(RouteElemet(uri: uri, cls: cls, style: style, option: option, check: { _ in true}))
    }
}
 
*/
