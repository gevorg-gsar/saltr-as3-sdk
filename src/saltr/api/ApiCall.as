package saltr.api {
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import saltr.resource.SLTResource;
import saltr.resource.SLTResourceURLTicket;
import saltr.saltr_internal;
import saltr.status.SLTStatus;

use namespace saltr_internal;

/**
 * @private
 */
public class ApiCall {
    saltr_internal static const MOBILE_CLIENT:String = "AS3-Mobile";
    saltr_internal static const WEB_CLIENT:String = "AS3-Web";
    saltr_internal static const API_VERSION:String = "1.0.0";

    protected var _url:String;
    protected var _params:Object;
    protected var _callback:Function;
    protected var _isMobile:Boolean;
    protected var _client:String;

    internal static function removeEmptyAndNullsJSONReplacer(k:*, v:*):* {
        if (v != null && v != "null" && v !== "") {
            return v;
        }
        return undefined;
    }

    internal static function getTicket(url:String, vars:URLVariables, timeout:int = 0):SLTResourceURLTicket {
        var ticket:SLTResourceURLTicket = new SLTResourceURLTicket(url, vars);
        ticket.method = URLRequestMethod.POST;
        if (timeout > 0) {
            ticket.idleTimeout = timeout;
        }
        return ticket;
    }

    public function ApiCall(params:Object, isMobile:Boolean = true) {
        _params = params;
        _isMobile = isMobile;
        _client = _isMobile ? MOBILE_CLIENT : WEB_CLIENT;
    }

    saltr_internal function call(callback:Function, timeout:int = 0):void {
        _callback = callback;
        var validationResult:Object = validateParams();
        if (validationResult.isValid == false) {
            returnValidationFailedResult(validationResult.message);
            return;
        }
        var urlVars:URLVariables = buildCall();
        doCall(urlVars, timeout);
    }

    private function returnValidationFailedResult(message:String):void {
        var apiCallResult:ApiCallResult = new ApiCallResult();
        apiCallResult.success = false;
        apiCallResult.status = new SLTStatus(SLTStatus.API_ERROR, message);
        _callback(apiCallResult);
    }

    private function doCall(urlVars:URLVariables, timeout:int):void {
        var ticket:SLTResourceURLTicket = ApiCall.getTicket(_url, urlVars, timeout);
        var resource:SLTResource = new SLTResource("apiCall", ticket, callRequestCompletedHandler, callRequestFailHandler);
        resource.load();
    }

    saltr_internal function callRequestCompletedHandler(resource:SLTResource):void {
        var jsonData:Object = resource.jsonData;
        var success:Boolean = false;
        var apiCallResult:ApiCallResult = new ApiCallResult();
        var response:Object;
        if (jsonData.hasOwnProperty("response")) {
            response = jsonData.response[0];
            success = response.success;
            if (success) {
                apiCallResult.data = response;
            } else {
                apiCallResult.status = new SLTStatus(response.error.code, response.error.message);
            }
        }
        else {
            var status:SLTStatus = new SLTStatus(SLTStatus.API_ERROR, "unknown API error: 'response' node is missing");
            apiCallResult.status = status;
        }

        apiCallResult.success = success;
        resource.dispose();
        _callback(apiCallResult);
    }

    saltr_internal function callRequestFailHandler(resource:SLTResource):void {
        resource.dispose();
        var apiCallResult:ApiCallResult = new ApiCallResult();
        apiCallResult.status = new SLTStatus(SLTStatus.API_ERROR, "API call request failed.");
        _callback(apiCallResult);
    }


    saltr_internal function buildCall():URLVariables {
        throw new Error("abstract method call error");
    }

    //TODO::daal. Now it is just an plain Object. Will be replaced with ValidationResult object...
    saltr_internal function validateParams():Object {
        if (_isMobile) {
            return validateMobileParams();
        }
        else {
            return validateWebParams();
        }
    }

    saltr_internal function validateMobileParams():Object {
        return validateDefaultMobileParams();
    }

    saltr_internal function validateWebParams():Object {
        return validateDefaultWebParams();
    }

    saltr_internal function validateDefaultMobileParams():Object {
        if (_params.deviceId == null) {
            return {isValid: false, message: "Field deviceId is required"};
        }
        return {isValid: true};
    }

    saltr_internal function validateDefaultWebParams():Object {
        if (_params.socialId == null) {
            return {isValid: false, message: "Field socialId is required"};
        }
        return {isValid: true};
    }

    saltr_internal function buildDefaultArgs():Object {
        var args:Object = {};
        if (_isMobile) {
            args.deviceId = _params.deviceId;
        }
        //socialId optional for Mobile, required for Web
        args.socialId = _params.socialId;
        args.apiVersion = ApiCall.API_VERSION;
        args.clientKey = _params.clientKey;
        args.client = _client;
        args.devMode = _params.devMode;
        return args;
    }
}
}