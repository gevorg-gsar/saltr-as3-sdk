/**
 * Created by TIGR on 2/27/2015.
 */
package {
import flash.display.Sprite;
import flash.display.Stage;

import org.flexunit.internals.TraceListener;
import org.flexunit.listeners.AirCIListener;
import org.flexunit.runner.FlexUnitCore;

import tests.saltr.SLTImportLevelsTest;
import tests.saltr.SLTSaltrMobileTest;

public class FlexUnitRunner extends Sprite {

    public static var STAGE:Stage;

    public function FlexUnitRunner() {
        onCreationComplete();
    }

    private function onCreationComplete():void {
        STAGE = stage;
        var core:FlexUnitCore = new FlexUnitCore();
        core.addListener(new TraceListener());
        core.addListener(new AirCIListener());
        core.visualDisplayRoot = STAGE;
        core.run(currentRunTestSuite());
    }

    public function currentRunTestSuite():Array {
        var testsToRun:Array = new Array();
//        testsToRun.push(tests.status.SLTStatusTest);
//        testsToRun.push(tests.status.SLTStatusSucessTest);
//        testsToRun.push(tests.status.SLTConnectTest);
        testsToRun.push(SLTSaltrMobileTest);
        testsToRun.push(SLTImportLevelsTest);
        return testsToRun;
    }
}
}
