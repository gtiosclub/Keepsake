//
//  TextBoxEntity.swift
//  Keepsake
//
//  Created by Shaunak Karnik on 3/4/25.
//

import SwiftUI
import RealityKit

class TextBoxEntity: Entity {
    
    private var textEntity: Entity
    private var textComponent: TextComponent
    
    init(text: String) async {
        
        
        // Creates the text box entity
        textEntity = Entity()
        
        // Create the TextComponent component (built-in component that includes a mesh background)
        textComponent = TextComponent()
        
        super.init()
        textComponent.backgroundColor = UIColor.white.cgColor
        
        // Separately instatiatied width and height to use in collision box dimensions
        let componentWidth: Float = 2000
        let componentHeight: Float = 1000
        textComponent.size = CGSize(width: Int(componentWidth), height: Int(componentHeight))
        textComponent.cornerRadius = 100
        
        // Set insets for now, need to figure out how to center text later
        textComponent.edgeInsets = UIEdgeInsets(top: 300, left: 500, bottom: 100, right: 200)
        
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
    
    func updateText(_ newText: String, font: String, size: CGFloat, isBold: Bool, isItalic: Bool, isUnderlined: Bool, textColor: Color, backgroundColor: Color?)
    {
        var attributedText = AttributedString(newText)
        
        // Create font descriptor with the specified font family
        var fontDescriptor: UIFontDescriptor
        
        // Try to create font descriptor with the requested font family
        // Check if the requested font exists
        if UIFont.fontNames(forFamilyName: font).count > 0 {
            // Font family exists, try to get the regular font
            if let font = UIFont(name: font, size: size) {
                fontDescriptor = font.fontDescriptor
            } else {
                // Fall back to system font if exact font name not found
                fontDescriptor = UIFont.systemFont(ofSize: size).fontDescriptor
                print("Exact font \(font) not found. Falling back to system font.")
            }
        } else {
            // Font family doesn't exist, use system font
            fontDescriptor = UIFont.systemFont(ofSize: size).fontDescriptor
            print("Font family \(font) not found. Falling back to system font.")
        }

        // Handle font traits
        var traits = UIFontDescriptor.SymbolicTraits()
        if isBold {
            // currentFont = .boldSystemFont(ofSize: size)
            traits.insert(.traitBold)
        }
        if isItalic {
            // currentFont = .italicSystemFont(ofSize: size)
            traits.insert(.traitItalic)
        }
        
        // update textColor
        attributedText.foregroundColor = textColor
        
        // attributedText.font = currentFont
        
        if !traits.isEmpty {
            fontDescriptor = fontDescriptor.withSymbolicTraits(traits) ?? fontDescriptor
        }
        
        let font = UIFont(descriptor: fontDescriptor, size: size)
        attributedText.font = font
        
        // Apply underline if needed
        // ***** Still does not work and needs fixing
        if isUnderlined {
            attributedText.underlineStyle = .single
            attributedText.underlineColor = .blue // Optional: Set a visible color
        }
        
        textComponent.text = attributedText
        
        // Update background color if provided
        if let backgroundColor = backgroundColor {
            textComponent.backgroundColor = backgroundColor.cgColor
        } else {
            textComponent.backgroundColor = UIColor.white.cgColor 
        }

        
        // Update the text entity's component
        textEntity.components[TextComponent.self] = textComponent
    }

    
    // Needed since this class is a subclass of Entity
    required init() {
        fatalError("init() has not been implemented")
    }
    
}
