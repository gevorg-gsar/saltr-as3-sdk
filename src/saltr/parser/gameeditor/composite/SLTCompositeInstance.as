/**
 * User: sarg
 * Date: 8/2/13
 * Time: 3:08 PM
 */
package saltr.parser.gameeditor.composite {
import saltr.parser.gameeditor.SLTAssetInstance;

public class SLTCompositeInstance extends SLTAssetInstance {
    private var _shifts:Array;

    public function SLTCompositeInstance(keys:Object, state:String, type:String) {
        super(keys, state, type);
    }

    public function get shifts():Array {
        return _shifts;
    }

    public function set shifts(value:Array):void {
        _shifts = value;
    }
}
}
