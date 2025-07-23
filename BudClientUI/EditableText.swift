//
//  EditableText.swift
//  BudClientiOS
//
//  Created by 김민우 on 7/23/25.
//
import SwiftUI


public struct EditableText: View {
    // MARK: state
    var text: String
    @Binding var textInput: String
    let submitHandler: () async -> Void
    
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool
    
    public init(text: String, textInput: Binding<String>, submitHandler: @escaping () async -> Void) {
        self.text = text
        self._textInput = textInput
        self.submitHandler = submitHandler
    }
    
    // MARK: view
    public var body: some View {
        // isEditing 상태에 따라 Text 또는 TextField를 보여줌
        Group {
            if isEditing {
                TextField("Enter new name", text: $textInput)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)   // 포커스 상태와 바인딩
                    .onSubmit {
                        // 'Return' 키를 누르면 실행될 액션
                        Task {
                            await submitHandler()
                        }
                    }
            } else {
                Text(text)
                    .onTapGesture {
                        // 텍스트를 탭하면 편집 모드로 전환
                        // 현재 이름을 text 상태에 복사하여 편집 시작
                        isEditing = true
                        isTextFieldFocused = true // 편집 모드 시작 시 바로 포커스
                    }
            }
        }
        // lifecycle
        .onDisappear {
            Task {
                await submitHandler()
            }
        }
    }
}
