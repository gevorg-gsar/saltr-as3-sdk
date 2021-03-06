/*
 * Copyright (c) 2014 Plexonic Ltd
 */

package saltr.game {
import flash.utils.Dictionary;
import saltr.saltr_internal;

use namespace saltr_internal;

/**
 * The SLTLevelParser class represents the level parser.
 * @private
 */
public class SLTLevelParser {

    /**
     * Class constructor.
     */
    public function SLTLevelParser() {
    }

    /**
     * Parses the level content.
     * @param rootNode The root node.
     * @param assetMap The asset map.
     * @return The parsed boards.
     */
    saltr_internal function parseLevelContent(rootNode:Object, assetMap:Dictionary):Dictionary {
        throw new Error("[SALTR: ERROR] parseLevelContent() is virtual method.");
    }

    saltr_internal function getBoardsNode(rootNode:Object):Object {
        var boardsNode:Object;
        if (rootNode.hasOwnProperty("boards")) {
            boardsNode = rootNode["boards"];
        } else {
            throw new Error("[SALTR: ERROR] Level content's 'boards' node can not be found.");
        }
        return boardsNode;
    }


    /**
     * Parses the level assets.
     * @return The parsed assets.
     */
    saltr_internal function parseLevelAssets(rootNode:Object):Dictionary {
        var assetNodes:Object = rootNode["assets"];
        var assetMap:Dictionary = new Dictionary();
        for (var assetId:Object in assetNodes) {
            assetMap[assetId] = parseAsset(assetNodes[assetId]);
        }
        return assetMap;
    }

    //Parsing assets here
    private function parseAsset(assetNode:Object):SLTAsset {
        var token:String;
        var statesMap:Dictionary;
        var properties:Object = null;

        if (assetNode.hasOwnProperty("token")) {
            token = assetNode.token;
        }

        if (assetNode.hasOwnProperty("states")) {
            statesMap = parseAssetStates(assetNode.states);
        }

        if (assetNode.hasOwnProperty("properties")) {
            properties = assetNode.properties;
        }

        return new SLTAsset(token, statesMap, properties);
    }

    private function parseAssetStates(stateNodes:Object):Dictionary {
        var statesMap:Dictionary = new Dictionary();
        for (var stateId:Object in stateNodes) {
            statesMap[stateId] = parseAssetState(stateNodes[stateId]);
        }

        return statesMap;
    }

    protected function parseAssetState(stateNode:Object):SLTAssetState {
        var token:String;
        var properties:Object = null;

        if (stateNode.hasOwnProperty("token")) {
            token = stateNode.token;
        }

        if (stateNode.hasOwnProperty("properties")) {
            properties = stateNode.properties;
        }

        return new SLTAssetState(token, properties);
    }

}
}
