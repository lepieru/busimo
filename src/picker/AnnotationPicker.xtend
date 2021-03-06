package picker

import entity.AnnotableNode

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtend.core.xtend.XtendMember
import org.eclipse.xtend.core.xtend.XtendClass
import org.eclipse.xtend.core.xtend.XtendField
import org.eclipse.xtend.core.xtend.XtendFunction
import java.util.List
import java.util.ArrayList
import java.util.Stack

/**
 * The annotation picker build an annotation storage
 * according to the XtendFile input.
 */
class AnnotationPicker
{
	/**
	 * Pick the annotation in the XtendFile
	 */
	def pick(XtendFile ast) {
		ast.visit
	}

	/* Private */

	@Accessors val List<AnnotableNode> rootNodes = new ArrayList<AnnotableNode>
	val stack = new Stack<AnnotableNode>

	private
	def void addNode(AnnotableNode node) {
		if (stack.isEmpty) rootNodes.add(node)
		else stack.peek.children.add(node)
	}

	private
	def dispatch void visit(XtendFile ast) {
		ast.xtendTypes.forEach[ visit ]
	}

	private
	def dispatch void visit(XtendMember member) {}

	private
	def dispatch void visit(XtendClass klass) {
		stack.push(new AnnotableNode(klass))
		klass.members.forEach[ visit ]
		val node = stack.pop
		addNode(node)
	}

	private
	def dispatch void visit(XtendField field) {
		if (!field.isExtension) addNode(new AnnotableNode(field))
	}

	private
	def dispatch void visit(XtendFunction function) {
		if (!function.isStatic) addNode(new AnnotableNode(function))
	}
}
