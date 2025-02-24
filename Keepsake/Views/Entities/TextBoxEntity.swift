//
//  TextBoxEntity.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 2/15/25.
//

import SwiftUI
import RealityKit

class TextBoxEntity: Entity {
    
    private var textEntity: Entity
    private var textComponent: TextComponent
    
    init(text: String) async {
        self.textEntity = Entity()
        self.textComponent = TextComponent()

        super.init()
        
//        // Creates the text box entity
//        let textEntity = Entity()
//        // Create the TextComponent component (built-in component that includes a mesh background)
//        var textComponent = TextComponent()
        
        textComponent.backgroundColor = CGColor(gray: 0.5, alpha: 0.8)
        
        // Separately instatiatied width and height to use in collision box dimensions
        let componentWidth: Float = 2000
        let componentHeight: Float = 1000
        textComponent.size = CGSize(width: Int(componentWidth), height: Int(componentHeight))
        textComponent.cornerRadius = 100
        
        // Set insets for now, need to figure out how to center text later
        textComponent.edgeInsets = UIEdgeInsets(top: 100, left: 200, bottom: 100, right: 200)
        
        // TextComponent takes in a Attributed String instead of a normal string so needs extra work to instantiate
        var attributedtext = AttributedString(text)
        attributedtext.font = .boldSystemFont(ofSize: 200)
        textComponent.text = attributedtext
        

        // Adds the component to the entity's set of components (each component gives the entity a different behavior)
        textEntity.components.set(textComponent)
        textEntity.components.set([InputTargetComponent(),
                                   CollisionComponent(shapes: [ShapeResource.generateBox(width: componentWidth, height: componentHeight, depth: 0.05),])])
        
        
        // Adds entity to parent view --> basically the "return" statement if my understanding is correct
        self.addChild(textEntity)
    }
    
    func updateText(_ newText: String) {
            var attributedText = AttributedString(newText)
            attributedText.font = .boldSystemFont(ofSize: 200)
            textComponent.text = attributedText
            
            // Update the text entity's component
            textEntity.components[TextComponent.self] = textComponent
    }
    
    // Needed since this class is a subclass of Entity
    required init() {
        fatalError("init() has not been implemented")
    }
    
}
