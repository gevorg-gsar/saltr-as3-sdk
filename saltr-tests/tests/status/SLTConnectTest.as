/**
 * Created by TIGR on 2/27/2015.
 */
package tests.status {
import flexunit.framework.Assert;

import saltr.SLTBasicProperties;
import saltr.SLTSaltrMobile;

public class SLTConnectTest {

    private var clientKey : String = "";
    private var deviceId : String = "";
    private var _saltr : SLTSaltrMobile;

    [Before]
    public function tearUp() : void {}

    [After]
    public function tearDown():void {}

    [Test (async)]
    public function testConnect():void {
        var asyncHandler : Function = AsyncUtil.asyncHandler(this, someCallback, null, 10000);
    }

    private function someCallback(data : *) :void  {
        Assert.assertEquals(data,12);
    }
}
}