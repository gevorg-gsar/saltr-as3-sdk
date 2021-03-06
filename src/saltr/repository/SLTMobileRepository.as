/*
 * Copyright (c) 2014 Plexonic Ltd
 */

package saltr.repository {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

/**
 * The SLTMobileRepository class represents the mobile repository.
 */
public class SLTMobileRepository implements ISLTRepository {

    private var _storageDirectory:File;
    private var _applicationDirectory:File;
    private var _cacheDirectory:File;
    private var _fileStream:FileStream;


    /**
     * Class constructor.
     */
    public function SLTMobileRepository() {
        _applicationDirectory = File.applicationDirectory;
        _storageDirectory = File.applicationStorageDirectory;
        _cacheDirectory = File.cacheDirectory;
        _fileStream = new FileStream();

//        trace("storageDirectory: " + _storageDirectory.nativePath);
//        trace("cacheDir: " + _cacheDirectory.nativePath);
    }

    /**
     * Provides an object from storage.
     * @param name The name of the object.
     * @return The requested object.
     */
    public function getObjectFromStorage(fileName:String):Object {
        var file:File = _storageDirectory.resolvePath(fileName);
        return getInternal(file);
    }

    /**
     * Provides an object from application.
     * @param fileName The name of the object.
     * @return The requested object.
     */
    public function getObjectFromApplication(fileName:String):Object {
        var file:File = _applicationDirectory.resolvePath(fileName);
        return getInternal(file);
    }

    /**
     * Provides an object from cache.
     * @param fileName The name of the object.
     * @return The requested object.
     */
    public function getObjectFromCache(fileName:String):Object {
        var file:File = _cacheDirectory.resolvePath(fileName);
        return getInternal(file);

    }

    /**
     * Provides the object's version.
     * @param name The name of the object.
     * @return The version of the requested object.
     */
    public function getObjectVersion(name:String):String {
        var file:File = _cacheDirectory.resolvePath(name.replace(".", "") + "_VERSION_");
        var obj:Object = getInternal(file);
        if (obj == null) {
            return null;
        }
        return obj["_VERSION_"];
    }

    /**
     * Caches an object.
     * @param name The name of the object.
     * @param version The version of the object.
     * @param object The object to store.
     */
    public function cacheObject(fileName:String, version:String, object:Object):void {
        var file:File = _cacheDirectory.resolvePath(fileName);
        saveInternal(file, object);
        file = _cacheDirectory.resolvePath(fileName.replace(".", "") + "_VERSION_");
        saveInternal(file, {_VERSION_: version});
    }

    /**
     * Stores an object.
     * @param name The name of the object.
     * @param object The object to store.
     */
    public function saveObject(fileName:String, objectToSave:Object):void {
        var file:File = _storageDirectory.resolvePath(fileName);
        saveInternal(file, objectToSave);
    }

    private function getInternal(file:File):Object {
        try {
            if (!file.exists) {
                return null;
            }
            _fileStream.open(file, FileMode.READ);
            var stringData:String = _fileStream.readUTFBytes(_fileStream.bytesAvailable);
            _fileStream.close();
            return stringData ? JSON.parse(stringData) : null;
        }
        catch (error:Error) {
            trace("[MobileStorageEngine] : error while getting object.\nError : [ID : '" + error.errorID + "', message : '" + error.message + "'");
        }
        return null;
    }

    private function saveInternal(file:File, objectToSave:Object):void {
        try {
            _fileStream.open(file, FileMode.WRITE);
            _fileStream.writeUTFBytes(JSON.stringify(objectToSave));
            _fileStream.close();
        }
        catch (error:Error) {
            trace("[MobileStorageEngine] : error while saving object.\nError : [ID : '" + error.errorID + "', message : '" + error.message + "'");
        }
    }
}
}
