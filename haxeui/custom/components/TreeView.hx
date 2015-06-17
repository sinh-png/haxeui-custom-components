package haxeui.custom.components;

import haxe.ui.toolkit.core.RootManager;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.core.interfaces.IItemRenderer;
import haxeui.custom.helpers.AssetHelper;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using haxeui.custom.helpers.BitmapDataHelper;
using haxeui.custom.helpers.StringHelper;

///////////////////////////////////////////////////////////////

class TreeView extends StaticListView {
	
	public var treeRoot(default, null):TreeViewItemContent;
	
	private var _showRoot:Bool = true;

	///////////////////////////////////////////////////////////////
	
	public function new() {
		super();
		
		root = RootManager.instance.currentRoot;
		
		createRootItem( { text:"root" } );
		_content.style.spacingY = 0;
		enableLeftClickSelection = false;
	}
	
	///////////////////////////////////////////////////////////////
	
	public function createRootItem(data:Dynamic):Void {
		treeRoot = new TreeViewItemContent(this, data);
	}
	
	override public function removeListItem(item:IItemRenderer, refresh_style:Bool = true):Void {
		super.removeListItem(item, refresh_style);
		AssetHelper.uncacheTempAsset(item.data.icon);
	}
	
	override function _onItemClick(e:UIEvent):Void {
		super._onItemClick(e);
		var item:IItemRenderer = cast e.displayObject;
		cast(item.userData.content, TreeViewItemContent).toggle();
	}
	
	///////////////////////////////////////////////////////////////
	
	public var showRoot(get, set):Bool;
	
	public function get_showRoot():Bool {
		return _showRoot;
	}
	
	public function set_showRoot(value:Bool):Bool {
		_showRoot = value;
		treeRoot._refreshRenderer();
		return _showRoot;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var selectedTreeItem(get, null):TreeViewItemContent;
	
	public function get_selectedTreeItem():TreeViewItemContent {
		return (selectedIndex >= 0) ? getItem(selectedIndex).userData.content : null;
	}
	
	///////////////////////////////////////////////////////////////
	
	public var hoveredTreeItem(get, null):TreeViewItemContent;
	
	public function get_hoveredTreeItem():TreeViewItemContent {
		return (_hoveredItem != null) ? _hoveredItem.userData.content : null;
	}
	
}

/*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
 *~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*/

@:allow(haxeui.custom.components.TreeView)
@:access(haxeui.custom.components.TreeView.treeRoot)
class TreeViewItemContent {
	
	public var tree(default, null):TreeView;
	public var parent(default, null):TreeViewItemContent = null;
	
	public var data(default, null):Dynamic;
	public var children(default, null):Array<TreeViewItemContent>;
	
	public var renderer(default, null):IItemRenderer;
	
	public var isOpening(default, null):Bool;
	
	public var onRemoved:TreeViewItemContent->Void;

	///////////////////////////////////////////////////////////////
	
	public function new(parent:Dynamic, data:Dynamic, index:Int = -1) {
		
		isOpening = true;
		children = new Array<TreeViewItemContent>();
		this.data = data;
		
		if (Std.is(parent, TreeView)) {
			tree = parent;
			tree.removeAllListItems();
			_refreshRenderer(false);
			
		} else if (Std.is(parent, TreeViewItemContent)) {
			this.parent = parent;
			tree = this.parent.tree;
			
			index = (index < 0 || index > this.parent.countChildren()) ? this.parent.countChildren() : index;
			this.parent.children.insert(index, this);
			
			if (this.parent.countChildren() == 1) {
				this.parent._refreshRenderer(false);
				_refreshRenderer(false);
			} else for (i in 0...index + 1) this.parent.children[i]._refreshRenderer();
			
			if (!this.parent.isOpening) _setVisible(false);
			
		} else throw "Invalid parent";
		
	}
	
	///////////////////////////////////////////////////////////////
	
	public function addItem(data:Dynamic, index:Int = -1):TreeViewItemContent {
		if (data.icon != null && Std.is(data.icon, String)) data.itemIcon = data.icon; 
		return new TreeViewItemContent(this, data, index);
	}
	
	public function remove():Void {
		for (child in children) child.remove();
		
		if (renderer != null) tree.removeListItem(renderer, false);
		
		if (parent == null) tree.treeRoot = null;
		else {
			var index = getIndex();
			parent.children.remove(this);
			if (index > 0) parent.children[index - 1]._refreshRenderer(true);
			else parent._refreshRenderer(false);
			parent = null;
		}
		
		if (onRemoved != null) onRemoved(this);
	}
	
	function _refreshRenderer(refresh_children:Bool = true, ?icon_bitmap:BitmapData):Void {
		var visible = true;
		
		if (Std.is(data.itemIcon, BitmapData)) icon_bitmap = data.itemIcon;

		if (renderer != null) {
			visible = renderer.visible;
			tree.removeListItem(renderer, false);
		}

		if (parent == null) {
			if (!tree.showRoot) {
				if (refresh_children) for (child in children) child._refreshRenderer();
				return;
			}

			var icon:BitmapData;
			if (icon_bitmap == null) icon = (data.itemIcon != null) ? Assets.getBitmapData(data.itemIcon) : null;
			else icon = icon_bitmap;
			
			if (countChildren() == 0) data.icon = UII.tree_empty_root__png;
			else if (isOpening) data.icon = UII.tree_opened_root__png;
			else data.icon = UII.tree_closed_root__png;
			
			if (icon != null) {
				icon = _squeezeIcon(icon);
				
				var bd = Assets.getBitmapData(data.icon);
				var bmd = new BitmapData(bd.width + icon.width, bd.height, true, 0x0);
				
				bmd.copyPixels(bd, new Rectangle(0, 0, bd.width, bd.height), new Point());
				bmd.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(bd.width));
				
				data.icon = AssetHelper.cacheTempAsset(bmd);
			}
			
			renderer = tree.addListItem(data, 0, false);
			
		} else {

			//////////////
			
			var vline = Assets.getBitmapData(UII.tree_vertical_line__png);
			var w = vline.width * getLayerIndex();
			if (tree.showRoot) w += vline.width;
			var h = vline.height;
			
			var icon:BitmapData;
			if (icon_bitmap == null) icon = (data.itemIcon != null) ? Assets.getBitmapData(data.itemIcon) : null;
			else icon = icon_bitmap;
			
			if (icon != null) {
				icon = _squeezeIcon(icon);
				w += icon.width;
			}

			var bmd = new BitmapData(w, h, true, 0x0);
			var pos = w;
			
			if (icon != null) {
				pos -= icon.width;
				bmd.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(pos));
			}

			pos -= vline.width;
			var bd:BitmapData;
			if (isLastItem()) {
				if (countChildren() == 0) bd = Assets.getBitmapData(UII.tree_last_empty_node__png);
				else {
					if (isOpening) bd = Assets.getBitmapData(UII.tree_last_opened_node__png);
					else bd = Assets.getBitmapData(UII.tree_last_closed_node__png);
				}
			} else {
				if (countChildren() == 0) bd = Assets.getBitmapData(UII.tree_mid_empty_node__png);
				else {
					if (isOpening) bd = Assets.getBitmapData(UII.tree_mid_opened_node__png);
					else bd = Assets.getBitmapData(UII.tree_mid_closed_node__png);
				}
			}
			bmd.copyPixels(bd, new Rectangle(0, 0, bd.width, h), new Point(pos));
			
			var item = parent;
			while (item != null) {
				pos -= vline.width;
				if (!item.isLastItem()) bmd.copyPixels(vline, new Rectangle(0, 0, vline.width, h), new Point(pos));
				item = item.parent;
			}
			
			data.icon = AssetHelper.cacheTempAsset(bmd);
			
			//////////////
			
			var parentRenderIndex = parent.getRenderIndex();
			var index = getIndex();
			pos = index + 1;
			for (i in 0...index) pos += parent.children[i].countChildren(true);

			//////////////
			
			renderer = tree.addListItem(data, parentRenderIndex + pos, false);
		}
		
		renderer.userData = { content: this };
		renderer.styleName = "treeItem";
		renderer.applyStyle();
		renderer.visible = visible;
		
		if (refresh_children) for (child in children) child._refreshRenderer();
	}
	
	public function countChildren(count_sub_child:Bool = false):Int {
		var i = children.length;
		
		if (count_sub_child) for (child in children) i += child.countChildren(true);
		
		return i;
	}
	
	public function countVisibleChildren():Int {
		if (!isOpening) return 0;
		
		var i = children.length;
		
		for (child in children) {
			if (child.isOpening) 
				i += child.countVisibleChildren();
		}
		
		return i;
	}
	
	public function getIndex():Int {
		if (parent == null) return -1;
		return parent.children.indexOf(this);
	}
	
	public function getLayerIndex():Int {
		var i = 0;
		var item = parent;
		while (item != null) {
			item = item.parent;
			i++;
		}
		
		return i;
	}
	
	public function getRenderIndex():Int {
		return (renderer != null) ? tree.getListItemIndex(renderer) : -1;
	}
	
	public function isLastItem():Bool {
		if (parent == null || getIndex() == parent.countChildren() - 1) return true;
		return false;
	}
	
	///////////////////////////////////////////////////////////////
	
	public function findChildren(data:Dynamic):Array<TreeViewItemContent> {
		var foundChildren = new Array<TreeViewItemContent>();
		
		for (child in children) {
			var fields = Reflect.fields(data);
			var  match = true;
			
			for (field in fields) {
				if (Reflect.field(this.data, field) != Reflect.field(data, field)) {
					match = false;
					break;
				}
			}
			
			if (match) foundChildren.push(child);
		}
		
		return foundChildren;
	}
	
	public function findFirstChildWithText(text:String, case_sensitive:Bool = true):TreeViewItemContent {
		for (child in children) {
			if (text.equal(child.data.text, case_sensitive)) return child;
		}
		return null;
	}
	
	///////////////////////////////////////////////////////////////
	
	function _setVisible(visible:Bool = true, opened_only:Bool = true):Void {
		if (renderer == null) return;
		
		renderer.visible = visible;
		if (!opened_only || isOpening) for (child in children) child._setVisible(visible);
	}
	
	public function open():Void {
		if (countChildren() == 0) return;
		
		for (child in children) child._setVisible();
		isOpening = true;
		_refreshRenderer(false);
	}
	
	public function close():Void {
		if (countChildren() == 0) return;
	
		for (child in children) child._setVisible(false);
		isOpening = false;
		_refreshRenderer(false);
	}
	
	public function toggle():Void {
		if (isOpening) close();
		else open();
	}
	
	///////////////////////////////////////////////////////////////
	
	public function setData(data:Dynamic):Void {
		this.data = data;
		_refreshRenderer(false);
	}
	
	public function setText(text:String):Void {
		data.text = text;
		_refreshRenderer(false);
	}
	
	public function setIcon(icon:Dynamic):Void {
		if (Std.is(icon, String)) {
			data.itemIcon = icon;
			_refreshRenderer(false);
		} else if (Std.is(icon, BitmapData)) {
			_refreshRenderer(false, icon);
		} else throw "Invalid icon";
	}
	
	function _squeezeIcon(icon:BitmapData):BitmapData {
		var h = Assets.getBitmapData(UII.tree_vertical_line__png).height;
		
		if (icon.height > h - 4) {
			var scale = (h - 4) / icon.height;
			var bmd = icon.createResizedBitmapData(scale, scale);
			icon = new BitmapData(bmd.width, h, true, 0x0);
			icon.copyPixels(bmd, new Rectangle(0, 0, bmd.width, bmd.height), new Point(0, (h - bmd.height) / 2));
		}
		
		return icon;
	}
	
}




