package haxeui.custom.helpers;

import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.RootManager;
import openfl.Lib;
import systools.Dialogs;
import ui.components.control.SimpleTextInputDialog;


///////////////////////////////////////////////////////////////

class DialogHelper {

	public static function showMessage(title:String, message:String, is_error:Bool = false):Void {
		var root = RootManager.instance.currentRoot;
		root.showModalOverlay(); 
		//root.invalidate();
		//Lib.current.stage.invalidate();
		
		Dialogs.message(title, message, is_error);
		
		root.hideModalOverlay(); 
	}
	
	public static function showConfirmation(?title:String, ?message:String, ?icon:Dynamic, on_comfirm:Void->Void, ?on_deny:Void->Void):Void {
		if (title == null) title = "Confirm";
		if (message == null) message = "Are you sure you want to continue this action?";
		PopupManager.instance.showSimple(message, title, PopupButton.YES | PopupButton.NO, function(button) {
			switch(button) {
				case PopupButton.YES: on_comfirm();
				case PopupButton.NO: if (on_deny != null) on_deny();
			}
		});
	}
	
	public static function getOpenDirectory(?title:String, ?message:String):String {
		var root = RootManager.instance.currentRoot;
		root.showModalOverlay(); 
		//root.invalidate();
		//Lib.current.stage.invalidate();
		
		var directory = Dialogs.folder(title == null ? "Select a folder" : title, message == null ? "Select a folder" : message);
	
		root.hideModalOverlay(); 
		return directory;
	}
	
	public static function getOpenFileName(?title:String, ?message:String, ?filters:Array<FileFilter>):Array<String> {
		var root = RootManager.instance.currentRoot;
		root.showModalOverlay(); 
		//root.invalidate();
		//Lib.current.stage.invalidate();
		
		if (filters == null) filters = [new FileFilter("All File (*.*)", "*.*")];
		
		var files = Dialogs.openFile(title == null ? "Select Files" : title, 
								message == null ? "Select Files" : message, 
								{ 
									count: filters.length, 
									descriptions: [for (filter in filters) filter.description],
									extensions: [for (filter in filters) filter.extension]	
								}
							);
				
		root.hideModalOverlay(); 				
		return files;
	}
	
	public static function openNameInput(title:String, label:String = "Name", default_text:String = "", ?on_finish:String->Void, ?text_check:String->String):Void {
		SimpleTextInputDialog.show(title, label, default_text, on_finish, text_check);
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

class FileFilter {
	
	public var description:String;
	public var extension:String;
	
	public function new(description:String, extension:String) {
		this.description = description;
		this.extension = extension;
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/