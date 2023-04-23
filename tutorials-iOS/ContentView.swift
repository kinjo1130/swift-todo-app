//
//  ContentView.swift
//  Shared
//
//  Created by 金城翔太郎 on 2023/04/16.
//

import SwiftUI
import Firebase

// todoの型を作成
struct Todo: Identifiable {
    let id: String
    let title: String
    var isEditing: Bool
}
struct TodoListView: View{
    var todo: Todo
    var body: some View{
        Text(todo.title)
    }
}


struct ContentView: View {
    @State var todos:[Todo] = [
    ];
    @State private var inputTitle = ""
    @State private var newTitle = ""
    var body: some View {
        VStack{
            Spacer().frame(height: 100)
            TextField("todoのタイトルを入力してください。", text: $inputTitle).textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            // 入力してもらったものを表示する
            Button("タスクを追加する"){
                if inputTitle.isEmpty{
                    return
                }
                else{
                    addTodos(title: inputTitle)
                    getTodoTasks()
                }
            }
            
            List(todos){
                todo in
                HStack(){
                    if todo.isEditing {
                        TextField("タイトル", text: $newTitle)
                    } else{
                        Text(todo.title)
                    }
                    Spacer()
                    if todo.isEditing {
                        Button(action:{
                            if newTitle.isEmpty {
                                print("空ですよ")
                            } else {
                                updateTodo(task: todo, newTitle: newTitle)
                            }
                        }) {
                            Text("保存")
                        }
                        Spacer()
                    } else {
                        Button(action:{
                            // 編集を押したら走る関数
                            updateItem(id: todo.id)
                        }) {
                            Text("編集")
                        }
                        
                        Button(action: {
                            // Firestoreからデータを削除する関数を呼び出す
                            deleteTodo(task: todo)
                        }, label: {
                            Text("削除").foregroundColor(.red)
                        }).buttonStyle(PlainButtonStyle())
                    }
                }
                }
            }
            .onAppear(){
                getTodoTasks()
            }
           
        }

    func updateItem(id: String){
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos[index].isEditing.toggle()
        }
        
    }
    func updateTodo(task:Todo, newTitle:String){
        let db = Firestore.firestore();
        db.collection("todos").document(task.id).updateData([
            "title": newTitle,
        ]) {
            err in
                if let err = err {
                    print("更新に失敗しました: \(err)")
                } else {
                    print("更新に成功しました")
                    getTodoTasks()
                }
        }
    }
    func deleteTodo(task: Todo){
        let db = Firestore.firestore();
        db.collection("todos").document(task.id).delete() {
            err in if let err = err{
                print("削除に失敗しました \(err)")
            }
            else{
                print("削除に成功しました。")
                self.todos = self.todos.filter { $0.id != task.id }
            }
        }
    }
    
    func addTodos(title: String){
        let db = Firestore.firestore()
        db.collection("todos").addDocument(data: ["title": title, "isDone": false])
        { err in
            if let err = err {
                print("タスクの追加に失敗しました: \(err)")
            } else {
                print("タスクの追加に成功しました")
            }
        }
        inputTitle = ""
    }
    
    func getTodoTasks(){
        let db = Firestore.firestore();
        db.collection("todos").getDocuments { snapshot, error in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            return
                        }
                        
                        todos = documents.map { document in
                            let data = document.data()
                            let id = document.documentID
                            let title = data["title"] as? String ?? ""
                            return Todo(id: id, title: title, isEditing: false)
                        }
                    }
        
    }
    
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
}

