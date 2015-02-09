package saltr.api {
import flash.net.URLVariables;

import saltr.SLTConfig;
import saltr.SLTSaltrMobile;
import saltr.saltr_internal;

use namespace saltr_internal;

/**
 * @private
 */
public class SendLevelEndEventApiCall extends ApiCall {

    public function SendLevelEndEventApiCall(params:Object, isMobile:Boolean = true):void {
        super(params, isMobile);
        _url = SLTConfig.SALTR_DEVAPI_URL;
    }

    override saltr_internal function buildCall():URLVariables {
        var urlVars:URLVariables = new URLVariables();
        urlVars.action = SLTConfig.ACTION_DEV_ADD_LEVELEND_EVENT;

        var args:Object = {
            clientKey: _params.clientKey,
            client: SLTSaltrMobile.CLIENT,
            devMode: _params.devMode,
            variationId: _params.variationId,
            apiVersion: SLTSaltrMobile.API_VERSION,
            deviceId: _params.deviceId
        }


        urlVars.deviceId = _params.deviceId;

        //optional for Mobile
        args.socialId = _params.socialId;

        var eventProps:Object = {};
        args.eventProps = eventProps;
        eventProps.endReason = _params.endReason;
        eventProps.endStatus = _params.endStatus;
        eventProps.score = _params.score;
        addLevelEndEventProperties(eventProps, _params.customNumbericProperties, _params.customTextProperties);


        urlVars.args = JSON.stringify(args, removeEmptyAndNullsJSONReplacer);
        return urlVars;
    }

    private function addLevelEndEventProperties(eventProps:Object, numericArray:Array, textArray:Array):Object {
        for (var i:int = 0; i < numericArray.length; i++) {
            var key:String = "cD" + (i + 1);
            eventProps[key] = numericArray[i];
        }
        for (var i:int = 0; i < textArray.length; i++) {
            var key:String = "cT" + (i + 1);
            eventProps[key] = textArray[i];
        }
        return eventProps;
    }
}
}