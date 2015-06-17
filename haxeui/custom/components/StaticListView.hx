package haxeui.custom.components;

import haxe.ui.toolkit.containers.ListView;
import haxe.ui.toolkit.core.interfaces.IItemRenderer;
import haxe.ui.toolkit.core.RootManager;
import haxe.ui.toolkit.events.UIEvent;
import openfl.events.MouseEvent;
import haxeui.custom.components.ContextMenu;

///////////////////////////////////////////////////////////////

class StaticListView extends ListView {
	
	///////////////////////////////////////////////////////////////
	
	private var _enableLeftClickSelection:Bool = true;
	private var _enableRightClickSelection:Bool = false;
	private var _enableContextMenuSelection:Bool = true;
	private var _enableContextMenu:Bool = false;
	
	private var _contextMenu:ContextMenu;
	private var _hoveredItem:IItemRenderer;
	
	///////////////////////////////////////////////////////////////
	
	public function new() {
		super();
		
		root = RootManager.instance.currentRoot;
		
		_contextMenu = new ContextMenu();
		_contextMenu.onMenuShow = _onMenuShow;
		_contextMenu.onMenuClose = _onMenuClose;
		
		_initEventListeners();
	}
	
	///////////////////////////////////////////////////////////////
	
	function _initEventListeners():Void {
		addEventListener(UIEvent.CLICK, _onListClick);
		addEventListener(MouseEvent.RIGHT_CLICK, _onListRightClick);
	}
	
	function _onListClick(e:UIEvent):Void {
		
	}
	
	function _onListRightClick(e:MouseEvent):Void {
		if (enableContextMenu && _hoveredItem == null) {
			_contextMenu.show(this);
		}
	}
	
	///////////////////////////////////////////////////////////////
	
	public function addListItem(data:Dynamic, index:Int = -1, refresh_style:Bool = true):IItemRenderer {
		index = (index < 0 || index > _content.numChildren) ? _content.numChildren : index;
		addListViewItem(null, data, index);
		var item:IItemRenderer = cast _content.getChildAt(index);

		if (refresh_style) _refreshItemStyle(index);
		_initItemEventListeners(item);
		
		return item;
	}
	
	public function replaceListItemData(data:Dynamic, index:Int):Void {
		var item:IItemRenderer = cast getListItemByIndex(index);
		item.data = data;
		_content.removeChild(item);
		_content.addChildAt(item, index);
	}
	
	public function getListItemIndex(item:IItemRenderer):Int {
		return _content.indexOfChild(item);
	}
	
	public function getListItemByIndex(index:Int):IItemRenderer {
		if (index < 0 || index > _content.numChildren - 1) index = _content.numChildren - 1;
		return cast _content.getChildAt(index);
	}
	
	public function getSelectedListItem():IItemRenderer {
		return getListItemByIndex(selectedIndex);
	}
	
	public function selectItem(item:IItemRenderer):Void {
		selectedIndex = getItemIndex(item);
	}
	
	public function removeListItem(item:IItemRenderer, refresh_style:Bool = true):Void {
		if (_content.indexOfChild(item) < 0) return;
		
		var index = getListItemIndex(item);
		_content.removeChild(item);
		if (refresh_style) _refreshItemStyle(index);
	}
	
	public function removeAllListItems():Void {
		_content.removeAllChildren();
	}
	
	public function sortListItemsByText():Void {
		_content.children.sort(function(item_1, item_2):Int {
			var a = cast(item_1, IItemRenderer).data.text.toLowerCase();
			var b = cast(item_2, IItemRenderer).data.text.toLowerCase();
			if (a < b) return -1;
			if (a > b) return 1;
			return 0;
		});
	}
	
	///////////////////////////////////////////////////////////////
	
	function _refreshItemStyle(start_index:UInt = 0):Void {
		var item:IItemRenderer;
		for (i in start_index..._content.numChildren) {
			item = cast _content.getChildAt(i); 
			if (!item.data.divider) {
				var styleName = (i % 2 == 0) ? "even" : "odd";
				item.styleName = styleName;
			}
		}
	}
	
	///////////////////////////////////////////////////////////////
	
	function _initItemEventListeners(item:IItemRenderer):Void {
		item.addEventListener(UIEvent.MOUSE_OVER, _onItemMouseOver);
		item.addEventListener(UIEvent.MOUSE_OUT, _onItemMouseOut);
		item.addEventListener(UIEvent.CLICK, _onItemClick);
		item.addEventListener(MouseEvent.RIGHT_CLICK, _onItemRightClick);
		item.addEventListener(UIEvent.REMOVED, _onItemRemove);
	}
	
	function _onItemMouseOver(e:UIEvent):Void {
		_hoveredItem = cast e.displayObject;
	}
	
	function _onItemMouseOut(e:UIEvent):Void {
		_hoveredItem = null;
	}
	
	function _onItemClick(e:UIEvent):Void {

	}
	
	function _onItemRightClick(e:MouseEvent):Void {
		if (_enableRightClickSelection) selectItem(_hoveredItem);
		if (enableContextMenu && contextMenu != null) _onItemSelectOpenMenu(_hoveredItem);
	}
	
	function _onItemRemove(e:UIEvent):Void {
		var item = e.displayObject;
		item.removeEventListener(UIEvent.MOUSE_OVER, _onItemMouseOver);
		item.removeEventListener(UIEvent.MOUSE_OUT, _onItemMouseOut);
		item.removeEventListener(UIEvent.CLICK, _onItemClick);
		item.removeEventListener(MouseEvent.RIGHT_CLICK, _onItemRightClick);
		item.removeEventListener(UIEvent.REMOVED, _onItemRemove);
	}
	
	function _onItemSelectOpenMenu(item:IItemRenderer):Void {
		if (_enableContextMenuSelection) selectItem(_hoveredItem);
		contextMenu.show(item);
	}
	
	///////////////////////////////////////////////////////////////
	
	public var hoveredListItem(get, null):IItemRenderer;
	
	public function get_hoveredListItem():IItemRenderer {
		return _hoveredItem;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var enableContextMenu(get, set):Bool;
	
	public function get_enableContextMenu():Bool {
		return _enableContextMenu;
	}
	
	public function set_enableContextMenu(value:Bool):Bool {
		return _enableContextMenu = value;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var contextMenu(get, set):ContextMenu;
	
	public function get_contextMenu():ContextMenu {
		return _contextMenu;
	}
	
	public function set_contextMenu(value:ContextMenu):ContextMenu {
		return _contextMenu = value;
	}
	
	///////////////////////////////////////////////////////////////
	
	function _onMenuShow(menu:ContextMenu):Void {

	}
	
	function _onMenuClose(menu:ContextMenu):Void {
		if (_enableContextMenuSelection) selectedIndex = -1;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var enableLeftClickSelection(get, set):Bool;
	
	public function get_enableLeftClickSelection():Bool {
		return _enableLeftClickSelection;
	}
	
	public function set_enableLeftClickSelection(value:Bool):Bool {
		return _enableLeftClickSelection = value;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var enableRightClickSelection(get, set):Bool;
	
	public function get_enableRightClickSelection():Bool {
		return _enableRightClickSelection;
	}
	
	public function set_enableRightClickSelection(value:Bool):Bool {
		return _enableRightClickSelection = value;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var enableContextMenuSelection(get, set):Bool;
	
	public function get_enableContextMenuSelection():Bool {
		return _enableContextMenuSelection;
	}
	
	public function set_enableContextMenuSelection(value:Bool):Bool {
		return _enableContextMenuSelection = value;
	}
	
	///////////////////////////////////////////////////////////////
	
	override function _onListItemClick(e:UIEvent):Void {
		if (enableLeftClickSelection) super._onListItemClick(e);
	}
	
	override function syncUI():Void {
	
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/