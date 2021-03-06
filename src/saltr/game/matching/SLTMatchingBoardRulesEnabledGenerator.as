/**
 * Created by TIGR on 3/25/2015.
 */
package saltr.game.matching {
import saltr.game.SLTAssetInstance;
import saltr.saltr_internal;

use namespace saltr_internal;

internal class SLTMatchingBoardRulesEnabledGenerator extends SLTMatchingBoardGeneratorBase {
    private static var INSTANCE:SLTMatchingBoardRulesEnabledGenerator;
    // Board generation try count without breaking asset distribution rules
    private static const TRY_COUNT_BREAKING_RULES_DISABLED:uint = 2;
    // Board generation try count with breaking asset distribution rules except distribution by count
    private static const TRY_COUNT_BREAKING_RULES_ENABLED:uint = 2;

    private var _boardConfig:SLTMatchingBoardConfig;
    private var _layer:SLTMatchingBoardLayer;
    private var _matchedAssetPositions:Vector.<MatchedAssetPosition>;

    saltr_internal static function getInstance():SLTMatchingBoardRulesEnabledGenerator {
        if (!INSTANCE) {
            INSTANCE = new SLTMatchingBoardRulesEnabledGenerator(new Singleton());
        }
        return INSTANCE;
    }

    public function SLTMatchingBoardRulesEnabledGenerator(singleton:Singleton) {
        if (singleton == null) {
            throw new Error("Class cannot be instantiated. Please use the method called getInstance.");
        }
    }

    override saltr_internal function generate(boardConfig:SLTMatchingBoardConfig, layer:SLTMatchingBoardLayer):void {
        _boardConfig = boardConfig;
        _layer = layer;
        if (null == _matchedAssetPositions) {
            _matchedAssetPositions = new Vector.<MatchedAssetPosition>();
        }
        parseFixedAssets(layer, _boardConfig.cells, _boardConfig.assetMap);
        parseMatchingRuleDisabledChunks();
        runGenerationTires(layer);
    }

    private function parseMatchingRuleDisabledChunks():void {
        var chunks:Vector.<SLTChunk> = new Vector.<SLTChunk>();
        for (var i:int = 0; i < _layer.chunks.length; ++i) {
            var chunk:SLTChunk = _layer.chunks[i];
            if (false == chunk.matchingRuleEnabled) {
                chunks.push(chunk);
            }
        }
        if (chunks.length > 0) {
            generateAssetData(chunks);
            fillLayerChunkAssets(chunks);
        }
    }

    private function getMatchingRuleEnabledChunks(layer:SLTMatchingBoardLayer):Vector.<SLTChunk> {
        var chunks:Vector.<SLTChunk> = new Vector.<SLTChunk>();
        for (var i:int = 0; i < _layer.chunks.length; ++i) {
            var chunk:SLTChunk = _layer.chunks[i];
            if (chunk.matchingRuleEnabled) {
                chunks.push(chunk);
            }
        }
        return chunks;
    }

    private function runGenerationTires(layer:SLTMatchingBoardLayer):void {
        // Tire 1 - Try to generate board without breaking asset distribution rules.
        for (var tier_1_i:int = 0; tier_1_i < TRY_COUNT_BREAKING_RULES_DISABLED; ++tier_1_i) {
            _matchedAssetPositions.length = 0;
            generateWithDisabledBreakingRules(layer);
            if (_matchedAssetPositions.length <= 0) {
                return; // Target reached. There is no need to go to next tire.
            }
        }
        // Tire 2 - Try generate board with breaking rules.
        for (var tier_2_i:int = 0; tier_2_i < TRY_COUNT_BREAKING_RULES_ENABLED; ++tier_2_i) {
            _matchedAssetPositions.length = 0;
            generateWithEnabledBreakingRules(layer);
            if (_matchedAssetPositions.length <= 0) {
                return; // Target reached. There is no need to go to next tire.
            }
        }
        // Tire 3 - Breaking matching rules board generation.
        _matchedAssetPositions.length = 0;
        generateWithForceEnabled(layer);
    }

    /*
     Board generation without breaking asset distribution rules
     */
    private function generateWithDisabledBreakingRules(layer:SLTMatchingBoardLayer):void {
        generateAssetData(getMatchingRuleEnabledChunks(layer));
        fillLayerChunkAssetsWithMatchingRules();
    }

    /*
     Board generation with breaking asset distribution rules except distribution by count
     */
    private function generateWithEnabledBreakingRules(layer:SLTMatchingBoardLayer):void {
        generateWithDisabledBreakingRules(layer);
        correctChunksMatchesWithChunkAssets();
    }

    private function generateWithForceEnabled(layer:SLTMatchingBoardLayer):void {
        generateWithEnabledBreakingRules(layer);
        fillLayerMissingChunkAssetsWithoutMatchingRules(layer);
    }

    private function fillLayerMissingChunkAssetsWithoutMatchingRules(layer:SLTMatchingBoardLayer):void {
        var correctionAssets:Vector.<SLTChunkAssetDatum> = null;
        for (var i:uint = 0; i < _matchedAssetPositions.length; ++i) {
            var matchedCellPosition:MatchedAssetPosition = _matchedAssetPositions[i];
            var chunk:SLTChunk = _layer.getChunkWithCellPosition(matchedCellPosition.col, matchedCellPosition.row);
            if (chunk.uniqueInAvailableAssetData.length > 0) {
                correctionAssets = chunk.uniqueInAvailableAssetData.concat();
            }
            if ((null == correctionAssets) || (null != correctionAssets && correctionAssets.length <= 0)) {
                correctionAssets = chunk.uniqueInCountAssetData.concat();
            }
            if (null != correctionAssets && correctionAssets.length > 0) {
                appendChunkAssetWithoutMatchCheck(correctionAssets[0], chunk, matchedCellPosition.col, matchedCellPosition.row);
                correctionAssets.length = 0;
                correctionAssets = null;
            }
        }
    }

    private function correctChunksMatchesWithChunkAssets():void {
        var correctionAssets:Vector.<SLTChunkAssetDatum>;
        var appendingResult:Boolean = false;
        var matchedAssetPositions:Vector.<MatchedAssetPosition> = _matchedAssetPositions.concat();

        for (var i:uint = 0; i < matchedAssetPositions.length; ++i) {
            var matchedCellPosition:MatchedAssetPosition = matchedAssetPositions[i];
            var chunk:SLTChunk = _layer.getChunkWithCellPosition(matchedCellPosition.col, matchedCellPosition.row);
            correctionAssets = chunk.uniqueInAvailableAssetData;
            for (var j:uint = 0; j < correctionAssets.length; ++j) {
                appendingResult = appendChunkAssetWithMatchCheck(correctionAssets[j], chunk, matchedCellPosition.col, matchedCellPosition.row);
                if (appendingResult) {
                    _matchedAssetPositions.splice(i, 1);
                    break;
                }
            }
        }
    }

    private function fillLayerChunkAssetsWithMatchingRules():void {
        var positionCells:Array = new Array();
        var chunkAvailableAssetData:Vector.<SLTChunkAssetDatum>;
        var assetDatum:SLTChunkAssetDatum;
        var appendResult:Boolean;

        for (var y:int = 0; y < _boardConfig.rows; ++y) {
            for (var x:int = 0; x < _boardConfig.cols; ++x) {
                positionCells.push([x, y]);
            }
        }

        var cellRandomIndex:uint = Math.floor(Math.random() * positionCells.length);
        var chunkAssetIndex:int = 0;

        while (positionCells.length > 0) {
            x = positionCells[ cellRandomIndex ][ 0 ];
            y = positionCells[ cellRandomIndex ][ 1 ];

            var chunk:SLTChunk = _layer.getChunkWithCellPosition(x, y);

            if (null != chunk && chunk.matchingRuleEnabled && chunk.availableAssetData.length > 0) {
                chunkAvailableAssetData = chunk.availableAssetData;

                assetDatum = null;
                if (chunkAssetIndex < chunkAvailableAssetData.length) {
                    assetDatum = chunkAvailableAssetData[ chunkAssetIndex ];
                }

                if (null != assetDatum && "" != assetDatum.assetToken) {
                    appendResult = appendChunkAssetWithMatchCheck(assetDatum, chunk, x, y);
                    if (appendResult) {
                        chunkAvailableAssetData.splice(chunkAssetIndex, 1);
                        positionCells.splice(cellRandomIndex, 1);
                        chunkAssetIndex = 0;
                        cellRandomIndex = Math.floor(Math.random() * positionCells.length);
                        removeFromMatchedAssetPosition(x, y);
                    }
                    else {
                        addMatchedAssetPosition(x, y);
                        ++chunkAssetIndex;
                    }
                }
                else {
                    chunkAssetIndex = 0;
                    positionCells.splice(cellRandomIndex, 1);
                    cellRandomIndex = Math.floor(Math.random() * positionCells.length);
                }
            }
            else {
                positionCells.splice(cellRandomIndex, 1);
                cellRandomIndex = Math.floor(Math.random() * positionCells.length);
            }
        }
    }

    private function addMatchedAssetPosition(x:uint, y:uint):void {
        var positionFound:Boolean = false;
        for (var i:uint = 0; i < _matchedAssetPositions.length; ++i) {
            var currentPosition:MatchedAssetPosition = _matchedAssetPositions[i];
            if (x == currentPosition.col && y == currentPosition.row) {
                positionFound = true;
                break;
            }
        }
        if (!positionFound) {
            _matchedAssetPositions.push(new MatchedAssetPosition(x, y));
        }
    }

    private function removeFromMatchedAssetPosition(x:uint, y:uint):void {
        for (var i:uint = 0; i < _matchedAssetPositions.length; ++i) {
            var currentPosition:MatchedAssetPosition = _matchedAssetPositions[i];
            if (x == currentPosition.col && y == currentPosition.row) {
                _matchedAssetPositions.splice(i, 1);
                break;
            }
        }
    }

    private function appendChunkAssetWithMatchCheck(assetDatum:SLTChunkAssetDatum, chunk:SLTChunk, col:uint, row:uint):Boolean {
        var matchesCount:int = _boardConfig.matchSize - 1;
        var horizontalMatches:int = calculateHorizontalMatches(assetDatum.assetToken, col, row);
        var verticalMatches:int = calculateVerticalMatches(assetDatum.assetToken, col, row);
        var squareMatch:Boolean = false;
        var excludedAsset:Boolean = false;
        var excludedMathAssets:Vector.<SLTChunkAssetDatum> = _boardConfig.excludedMatchAssets;

        if (_boardConfig.squareMatchingRuleEnabled) {
            squareMatch = checkSquareMatch(assetDatum.assetToken, col, row);
        }

        for (var i:uint = 0; i < excludedMathAssets.length; ++i) {
            if (assetDatum.assetId == excludedMathAssets[i].assetId) {
                excludedAsset = true;
                break;
            }
        }

        if (excludedAsset || (horizontalMatches < matchesCount && verticalMatches < matchesCount && !squareMatch)) {
            addAssetInstanceToChunk(assetDatum, chunk, col, row);
            return true;
        }
        return false;
    }

    private function appendChunkAssetWithoutMatchCheck(assetDatum:SLTChunkAssetDatum, chunk:SLTChunk, col:uint, row:uint):void {
        addAssetInstanceToChunk(assetDatum, chunk, col, row);
    }

    private function calculateHorizontalMatches(assetToken:String, col:uint, row:uint):int {
        var i:int = 1;
        var hasMatch:Boolean = true;
        var matchesCount:int = _boardConfig.matchSize - 1;
        var siblingCellAssetToken:String;
        var horizontalMatches:uint = 0;

        while (i <= Math.min(col, matchesCount) && hasMatch) {
            siblingCellAssetToken = getAssetTokenAtPosition(_boardConfig.cells, col - i, row, _layer.token);
            hasMatch = (assetToken == siblingCellAssetToken);
            if (hasMatch) {
                ++horizontalMatches;
                ++i;
            }
        }

        i = 1;
        hasMatch = true;

        while (i <= Math.min(_boardConfig.cols - col - 1, matchesCount) && hasMatch) {
            siblingCellAssetToken = getAssetTokenAtPosition(_boardConfig.cells, col + i, row, _layer.token);
            hasMatch = (assetToken == siblingCellAssetToken);
            if (hasMatch) {
                ++horizontalMatches;
                ++i;
            }
        }

        return horizontalMatches;
    }

    private function calculateVerticalMatches(assetToken:String, col:uint, row:uint):int {
        var i:int = 1;
        var hasMatch:Boolean = true;
        var matchesCount:int = _boardConfig.matchSize - 1;
        var siblingCellAssetToken:String;
        var verticalMatches:uint = 0;

        while (i <= Math.min(row, matchesCount) && hasMatch) {
            siblingCellAssetToken = getAssetTokenAtPosition(_boardConfig.cells, col, row - i, _layer.token);
            hasMatch = (assetToken == siblingCellAssetToken);
            if (hasMatch) {
                ++verticalMatches;
                ++i;
            }
        }

        i = 1;
        hasMatch = true;

        while (i <= Math.min(_boardConfig.rows - row - 1, matchesCount) && hasMatch) {
            siblingCellAssetToken = getAssetTokenAtPosition(_boardConfig.cells, col, row + i, _layer.token);
            hasMatch = (assetToken == siblingCellAssetToken);
            if (hasMatch) {
                ++verticalMatches;
                ++i;
            }
        }

        return verticalMatches;
    }

    private function checkSquareMatch(assetToken:String, col:uint, row:uint):Boolean {
        var directionMatchesCount:uint = 0;
        var directions:Array = [
            [
                [ -1, 0 ],
                [ -1, -1 ],
                [ 0, -1 ]
            ],
            [
                [ 0, -1 ],
                [ 1, -1 ],
                [ 1, 0 ]
            ],
            [
                [ 1, 0 ],
                [ 1, 1 ],
                [ 0, 1 ]
            ],
            [
                [ 0, 1 ],
                [ -1, 1 ],
                [ -1, 0 ]
            ]
        ];
        var direction:Object;
        var hasMatch:Boolean = false;
        var siblingCellAssetToken:String;

        for (var i:uint = 0; i < directions.length; ++i) {
            directionMatchesCount = 0;
            direction = directions[ i ];

            for (var j:uint = 0; j < direction.length; ++j) {
                siblingCellAssetToken = getAssetTokenAtPosition(_boardConfig.cells, col + direction[j][0], row + direction[j][1], _layer.token);

                if (assetToken == siblingCellAssetToken) {
                    ++directionMatchesCount;
                }
                else {
                    break;
                }
            }

            if (directionMatchesCount == 3) {
                hasMatch = true;
                break;
            }
        }

        return hasMatch;
    }

    private function getAssetTokenAtPosition(boardCells:SLTCells, col:int, row:int, layerToken:String):String {
        var assetToken:String = "";
        if (col < 0 || row < 0) {
            return assetToken;
        }
        var cell:SLTCell = boardCells.retrieve(col, row);
        if (null != cell) {
            var assetInstance:SLTAssetInstance = cell.getAssetInstanceByLayerId(layerToken);
            if (null != assetInstance) {
                assetToken = cell.getAssetInstanceByLayerId(layerToken).token;
            }
        }
        return assetToken;
    }

    private function addAssetInstanceToChunk(assetDatum:SLTChunkAssetDatum, chunk:SLTChunk, col:uint, row:uint):void {
        chunk.addAssetInstanceWithPosition(assetDatum, col, row);
    }
}
}

class Singleton {
}

class MatchedAssetPosition {
    private var _col:uint;
    private var _row:uint;

    public function MatchedAssetPosition(col:uint, row:uint):void {
        _col = col;
        _row = row;
    }

    public function get col():uint {
        return _col;
    }

    public function get row():uint {
        return _row;
    }
}