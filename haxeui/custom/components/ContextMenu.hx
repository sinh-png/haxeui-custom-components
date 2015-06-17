package haxeui.custom.components;

import haxe.ui.toolkit.controls.Menu;
import haxe.ui.toolkit.controls.MenuItem;
import haxe.ui.toolkit.controls.MenuSeparator;
import haxe.ui.toolkit.core.RootManager;
import haxe.ui.toolkit.events.MenuEvent;
import haxe.ui.toolkit.events.UIEvent;

///////////////////////////////////////////////////////////////

class ContextMenu extends Menu {
	
	public var target(default, null):Dynamic;
	
	public var onMenuShow:ContextMenu->Void;
	public var onMenuClose:ContextMenu->Void;
	
	private var isHovered:Bool = false;
	
	///////////////////////////////////////////////////////////////

	public function new() {
		super();
		
		root = RootManager.instance.currentRoot;	
		root.addEventListener(UIEvent.MOUSE_DOWN, __onRootMouseDown);
		root.addEventListener(UIEvent.REMOVED_FROM_STAGE, _onRootRemoved);
		
		onMouseOver = _onMouseOver;
		onMouseOut = _onMouseOut;
		addEventListener(MenuEvent.SELECT, _onMenuSelect);
	}
	
	///////////////////////////////////////////////////////////////
	
	function _onMenuSelect(e:MenuEvent):Void {
		var menuItem:ContextMenuItem = cast e.menuItem;
		menuItem.target = target;
		
		var callback:ContextMenuItem->Void = menuItem.userData.onClick;
		if (callback != null) callback(menuItem);
		
		close();
	}
	
	///////////////////////////////////////////////////////////////
	
	public function show(?target:Dynamic):Void {
		this.target = target;
		
		var mx = root.mousePosition.x;
		var my = root.mousePosition.y;
		
		var sw = root.width;
		var sh = root.height;
		
		x = mx > sw - 160 ?  sw - 160 : mx;
		y = my;
		
		root.addChild(this);
		
		if (onMenuShow != null) onMenuShow(this);
	}
	
	public function close():Void {
		if (root.indexOfChild(this) > -1) root.removeChild(this, false);
		if (onMenuClose != null) onMenuClose(this);
	}
	
	///////////////////////////////////////////////////////////////
	
	public function addItem(text:String, ?on_select:ContextMenuItem->Void):ContextMenuItem {
		var item = new ContextMenuItem();
		item.text = text;
		item.userData = { onClick: on_select };
		return cast addChild(item);
	}
	
	public function addSeparator():MenuSeparator {
		return cast addChild(new MenuSeparator());
	}
	
	///////////////////////////////////////////////////////////////
	
	function _onMouseOver(e:UIEvent):Void {
		isHovered = true;
	}
		
	function _onMouseOut(e:UIEvent):Void {
		isHovered = false;
	}
	
	function __onRootMouseDown(e:UIEvent):Void {
		if (!isHovered) close();
	}
	
	function _onRootRemoved(e:UIEvent):Void {
		root.removeEventListener(UIEvent.MOUSE_DOWN, __onRootMouseDown);
		root.removeEventListener(UIEvent.REMOVED_FROM_STAGE, _onRootRemoved);
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

@:allow(haxeui.custom.components.ContextMenu)
class ContextMenuItem extends MenuItem {
	
	public var target(default, null):Dynamic;
	
	public function new() {
		super();
	}
	
}





