/*
 * Copyright (c) 2014 Plexonic Ltd
 */

package saltr.game.matching {
import saltr.saltr_internal;

use namespace saltr_internal;

/**
 * The SLTChunkAssetRule class represents the asset's rule.
 */
internal class SLTChunkAssetRule {

    saltr_internal static const ASSET_DISTRIBUTION_TYPE_COUNT:String = "count";
    saltr_internal static const ASSET_DISTRIBUTION_TYPE_RATIO:String = "ratio";
    saltr_internal static const ASSET_DISTRIBUTION_TYPE_RANDOM:String = "random";

    private var _assetId:String;
    private var _stateIds:Array;
    private var _distributionType:String;
    private var _distributionValue:uint;

    /**
     * Class constructor.
     * @param assetId The asset identifier.
     * @param distributionType The distribution type.
     * @param distributionValue The distribution value.
     * @param stateIds The state identifiers.
     */
    public function SLTChunkAssetRule(assetId:String, distributionType:String, distributionValue:uint, stateIds:Array) {

        _assetId = assetId;
        _distributionType = distributionType;
        _distributionValue = distributionValue;
        _stateIds = stateIds;
    }

    /**
     * The asset identifier.
     */
    public function get assetId():String {
        return _assetId;
    }

    /**
     * The distribution value.
     */
    public function get distributionValue():uint {
        return _distributionValue;
    }

    /**
     * The distribution type.
     */
    public function get distributionType():String {
        return _distributionType;
    }

    /**
     * The The state identifiers.
     */
    public function get stateIds():Array {
        return _stateIds;
    }
}
}
