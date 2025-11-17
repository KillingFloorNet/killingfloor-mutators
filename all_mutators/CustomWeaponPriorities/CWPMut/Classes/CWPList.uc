/* A list of weapon classes ordered by priority. */
class CWPList extends Object;

var CWPNode Head, Tail;
var int itemCount;

function AddNode(class<KFWeapon> aWeaponClass) {
	local CWPNode NewTail;
	
	NewTail = new(None) class'CWPNode';
	NewTail.WeaponClass = aWeaponClass;

	if (Tail != None) {
		Tail.Next = NewTail;
		Tail = NewTail;
	}
	else {
		Tail = NewTail;
		Head = Tail;
	}
	
	itemCount++;
}

function InsertNode(class<KFWeapon> aWeaponClass, out CWPNode aNode) {
	local CWPNode NewNode;
	
	NewNode = new(None) class'CWPNode';
	NewNode.WeaponClass = aNode.WeaponClass;
	if (aNode.Next != None)
		NewNode.Next = aNode.Next;
	else
		Tail = NewNode;

	aNode.WeaponClass = aWeaponClass;
	aNode.Next = NewNode;
	
	itemCount++;
}

function InsertHead(class<KFWeapon> aWeaponClass) {
	InsertNode(aWeaponClass, Head);
}

function AddInOrder(class<KFWeapon> aWeaponClass) {
	local CWPNode N;
	
	for (N = Head; N != None; N = N.Next)
		if (aWeaponClass.default.priority > N.WeaponClass.default.priority)
			break;
	
	if (N != None)
		InsertNode(aWeaponClass, N);
	else
		AddNode(aWeaponClass);
}