package main

import generator.MetamodelGenerator
import generator.ModelGenerator
import generator.DesignGenerator
import generator.RepresentationGenerator
import picker.AnnotationPicker
import util.Utils

import org.eclipse.emf.ecore.EPackage

class Busimo
{
	def static void main(String[] args) {
		make
		println("Busimo tasks finished.")
	}

	def static make() {
		val path = 'assets/inputs/EcoreTest.xtend'
		val picker = new AnnotationPicker
		picker.pick(Utils::loadXtendFile(path))

		val metamodelGenerator = new MetamodelGenerator
		metamodelGenerator.generate(picker)
		val metamodel = metamodelGenerator.result
		Utils::saveModel(metamodel, '''./assets/gen/a/metamodel.ecore''', "ecore")

		val modelGenerator = new ModelGenerator(picker, metamodel as EPackage)
		modelGenerator.generate(picker)
		val model = modelGenerator.result
		Utils::saveModelToXmi(model, '''./assets/gen/model.xmi''', "*")

		val designGenerator = new DesignGenerator
		val design = designGenerator.generate(metamodel as EPackage)
		Utils::saveModel(design, '''./assets/gen/style.odesign''')

		val representationGenerator = new RepresentationGenerator
		representationGenerator.generate
		val represensation = representationGenerator.result
		Utils::saveModel(represensation, '''./assets/gen/representation.aird''')
	}
}
