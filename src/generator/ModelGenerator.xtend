package generator

import picker.AnnotationPicker
import entity.Annotation

import org.eclipse.xtend.core.xtend.XtendFunction
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EFactory
import java.util.List

class ModelGenerator
{
	new(AnnotationPicker picker, EPackage metamodel) {
		this.picker = picker
		this.metamodel = metamodel
		this.factory = metamodel.EFactoryInstance
		this.model = factory.create(findClass("BusinessContainer"))
	}

	def generate(AnnotationPicker picker) {
		picker.annotations.all.forEach[ visit ]
		return result
	}

	def result() {
		return model
	}

	/* Private */

	var AnnotationPicker picker
	var EObject model
	var EPackage metamodel
	var EFactory factory

	def private dispatch void visit(Annotation annotation) {
		val annotationName = annotation.XAnnotation.annotationType.simpleName
		val businessClass = findClass(annotationName.toFirstUpper)
		val businessObject = factory.create(businessClass)

		val xtendMember = businessClass.EAllAttributes.findFirst[ name == "xtendMember" ]
		val method = (annotation.XTarget as XtendFunction).name
		businessObject.eSet(xtendMember, method)

		val businessClassList = findClassList(businessClass)
		businessObjectsReference(businessClassList).add(businessObject)
	}

	def private findClass(String name) {
		return metamodel.EClassifiers.findFirst[ eObject |
			(eObject instanceof EClass) && eObject.name == name
		] as EClass
	}

	def private findClassList(EClass eClass) {
		return metamodel.EClassifiers.findFirst[ eObject |
			(eObject instanceof EClass) && eObject.name == eClass.name + "List"
		] as EClass
	}

	def private businessObjectListInstance(EClass businessClassList) {
		val objectLists = businessObjectListsReference
		var list = objectLists.findFirst[ eObject |
			(eObject as EObject).eClass == businessClassList
		]
		if (list == null) {
			list = factory.create(businessClassList)
			objectLists.add(list)
		}
		return list
	}

	def private businessObjectsReference(EClass businessClassList) {
		val businessObjectList = businessObjectListInstance(businessClassList)
		val reference = businessClassList.EAllReferences.findFirst[ name == "objects" ]
		return businessObjectList.eGet(reference) as List<EObject>
	}

	def private businessObjectListsReference() {
		val reference = model.eClass.EAllReferences.findFirst[ name == "objectLists" ]
		return model.eGet(reference) as List<EObject>
	}
}
