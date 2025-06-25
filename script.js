document.addEventListener("DOMContentLoaded", () => {
    const list = document.getElementById('todo-list');

    fetch('todos.json')
        .then(response => {
            if (!response.ok) {
                throw new Error("Fehler beim Laden der todos.json");
            }
            return response.json();
        })
        .then(todos => {
            todos.forEach(todo => {
                const li = document.createElement('li');
                li.textContent = `${todo.owner}: ${todo.text}`;
                if (todo.done) {
                    li.style.textDecoration = 'line-through';
                }
                list.appendChild(li);
            });
        })
        .catch(error => {
            console.error("Fehler beim Laden oder Parsen der Todos:", error);
            const li = document.createElement('li');
            li.textContent = "Fehler beim Laden der Aufgaben.";
            li.style.color = "red";
            list.appendChild(li);
        });
});