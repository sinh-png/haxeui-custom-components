package;

import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.selection.ListSelector;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.themes.GradientTheme;
import haxeui.custom.components.ContextMenu.ContextMenuItem;
import haxeui.custom.components.TreeView;
import openfl.display.Sprite;

class Main extends Sprite {

	public function new() {
		super();
		
		Toolkit.theme = "gradient";
		Toolkit.init();
		Toolkit.openFullscreen(function(root:Root) {
			
			var box = new VBox();
			box.percentWidth = box.percentHeight = 100;
			box.style.padding = 5;
			root.addChild(box);
			
			var text = new Text();
			text.text = "Right click to open context menu.";
			box.addChild(text);
			
			///////////////////////////////////////////////////////////////
			
			var tree = new TreeView();
			tree.width = 400; 
			tree.percentHeight = 100;
			
			///////////////////////////////////////////////////////////////
			
			var item1 = tree.treeRoot.addItem( { text: "Item 1", itemIcon: "img/icons/folder.png" } );
			var item2 = tree.treeRoot.addItem( { text: "Item 2" } );
			var item3 = tree.treeRoot.addItem( { text: "Item 3" } );
			
			item1.addItem( { text: "Item 1.1" } ); 
			var item2_1 = item2.addItem( { text: "Item 1", itemIcon: "img/icons/folder.png" } );
			item3.addItem( { text: "Item 3.1", itemIcon: "img/icons/burger.png" } ); 
			
			item2_1.addItem( { text: "Item 2.1.2", itemIcon: "img/icons/cherry.png" } );
			item2_1.addItem( { text: "Item 2.1.3", itemIcon: "img/icons/butterfly.png" } );
			var item2_1_4 = item2_1.addItem( { text: "Item 1", itemIcon: "img/icons/folder.png" } );
			
			var a = item2_1_4.addItem( { text: "Item 2.1.4.1" } );
			
			///////////////////////////////////////////////////////////////
			
			tree.enableContextMenu = true;
			
			tree.contextMenu.addMenuItem("Hide root", function(menuItem:ContextMenuItem) {
				tree.showRoot = !tree.showRoot;
				if (tree.showRoot) menuItem.text = "Hide root"; else menuItem.text = "Show root";
			});
			
			tree.contextMenu.addMenuSeparator();
			
			var menuItemAdd = tree.contextMenu.addMenuItem("Add item", function(menuItem) {
				var selectedItem = (tree.selectedIndex == -1) ? tree.treeRoot : tree.selectedTreeItem;
				
				var vbox = new VBox();
				vbox.percentWidth = 100;
				
				var hbox = new HBox();
				hbox.percentWidth = 100;
				hbox.style.spacingX = 5;
				vbox.addChild(hbox);
				
				var label = new Text();
				label.text = "Item Name:";
				hbox.addChild(label);
				
				var textInput = new TextInput();
				textInput.percentWidth = 100;
				hbox.addChild(textInput);
				
				var hbox = new HBox();
				hbox.percentWidth = 100;
				hbox.style.spacingX = 5;
				vbox.addChild(hbox);
				
				label = new Text();
				label.text = "Icon:";
				hbox.addChild(label);
				
				var iconList = new ListSelector();
				iconList.percentWidth = 100;
				iconList.dataSource.add( { text: "Folder", icon: "img/icons/folder.png" } );
				iconList.dataSource.add( { text: "Cherry", icon: "img/icons/cherry.png" } );
				iconList.dataSource.add( { text: "Butterfly", icon: "img/icons/butterfly.png" } );
				iconList.dataSource.add( { text: "Burger", icon: "img/icons/burger.png" } );
				iconList.selectedIndex = 0;
				iconList.style.icon = "img/icons/folder.png";
				iconList.style.iconPosition = "left";
				iconList.onChange = function(e) iconList.style.icon = "img/icons/" + iconList.text.toLowerCase() + ".png";
				hbox.addChild(iconList);
				
				PopupManager.instance.showCustom(vbox, "Add Item", PopupButton.OK | PopupButton.CANCEL, function(button) {
					if (button == PopupButton.OK) {
						selectedItem.addItem({ 
							text: textInput.text,
							icon: iconList.style.icon
						});
					}
				});
			});
			
			var menuItemRemove = tree.contextMenu.addMenuItem("Remove item", function(menuItem) {
				tree.selectedTreeItem.remove();
			});
			
			tree.contextMenu.onMenuShow = function(menu) {
				menuItemRemove.visible = (tree.hoveredTreeItem == null) ? false : true;
			}
			
			///////////////////////////////////////////////////////////////
			
			box.addChild(tree);

		});
	}

}
