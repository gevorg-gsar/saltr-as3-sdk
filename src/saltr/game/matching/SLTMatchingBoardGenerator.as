/**
 * Created by TIGR on 3/25/2015.
 */
package saltr.game.matching {
import saltr.saltr_internal;

use namespace saltr_internal;

internal class SLTMatchingBoardGenerator extends SLTMatchingBoardGeneratorBase {
    private static var INSTANCE:SLTMatchingBoardGenerator;

    private var _boardConfig:SLTMatchingBoardConfig;
    private var _layer:SLTMatchingBoardLayer;

    saltr_internal static function getInstance():SLTMatchingBoardGenerator {
        if (!INSTANCE) {
            INSTANCE = new SLTMatchingBoardGenerator(new Singleton());
        }
        return INSTANCE;
    }

    public function SLTMatchingBoardGenerator(singleton:Singleton) {
        if (singleton == null) {
            throw new Error("Class cannot be instantiated. Please use the method called getInstance.");
        }
    }

    override saltr_internal function generate(boardConfig:SLTMatchingBoardConfig, layer:SLTMatchingBoardLayer):void {
        _boardConfig = boardConfig;
        _layer = layer;
        parseFixedAssets(layer, _boardConfig.cells, _boardConfig.assetMap);
        generateAssetData(_layer.chunks);
        fillLayerChunkAssets(_layer.chunks);
    }
}
}

class Singleton {
}