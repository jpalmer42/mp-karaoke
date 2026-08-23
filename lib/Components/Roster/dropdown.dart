// class DialogDropdown extends StatefulWidget {
//   final Widget child;
//   final List<Widget> items;
//   final ValueChanged<int?>? onSelected;

//   const DialogDropdown({
//     super.key,
//     required this.child,
//     required this.items,
//     this.onSelected,
//   });

//   @override
//   State<DialogDropdown> createState() => _DialogDropdownState();
// }

// class _DialogDropdownState extends State<DialogDropdown> {
//   final LayerLink _layerLink = LayerLink();
//   bool _isOpen = false;
//   OverlayEntry? _overlayEntry;

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: GestureDetector(
//         onTap: _toggleDropdown,
//         child: widget.child,
//       ),
//     );
//   }

//   void _toggleDropdown() {
//     if (_isOpen) {
//       _closeDropdown();
//     } else {
//       _showDropdown();
//     }
//   }

//   void _showDropdown() {
//     final renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: Offset(0, size.height),
//           child: Material(
//             elevation: 4,
//             child: ListView(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               children: widget.items
//                   .asMap()
//                   .entries
//                   .map(
//                     (entry) => ListTile(
//                       title: entry.value,
//                       onTap: () {
//                         widget.onSelected?.call(entry.key);
//                         _closeDropdown();
//                       },
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//     setState(() => _isOpen = true);
//   }

//   void _closeDropdown() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     setState(() => _isOpen = false);
//   }

//   @override
//   void dispose() {
//     _closeDropdown();
//     super.dispose();
//   }
// }
