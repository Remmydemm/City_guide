//
//  PersonaSelectorView.swift
//  StuttgartGuide
//
//  Persona selection interface
//

import SwiftUI

struct PersonaSelectorView: View {
    @Binding var selectedPersona: Persona

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Your Guide")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Persona.allCases) { persona in
                        PersonaButton(
                            persona: persona,
                            isSelected: selectedPersona == persona,
                            action: { selectedPersona = persona }
                        )
                    }
                }
            }
        }
    }
}

struct PersonaButton: View {
    let persona: Persona
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: persona.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(persona.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 90, height: 80)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PersonaSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        PersonaSelectorView(selectedPersona: .constant(.historyBuff))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
