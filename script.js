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

                const label = document.createElement('label');
                label.style.display = 'flex';
                label.style.alignItems = 'center';
                label.style.gap = '10px';

                const checkbox = document.createElement('input');
                checkbox.type = 'checkbox';
                checkbox.checked = todo.done;

                const span = document.createElement('span');
                span.textContent = `${todo.owner}: ${todo.text}`;

                if (todo.done) {
                    span.style.textDecoration = 'line-through';
                }

                checkbox.addEventListener('change', () => {
                    span.style.textDecoration = checkbox.checked ? 'line-through' : 'none';
                });

                label.appendChild(checkbox);
                label.appendChild(span);
                li.appendChild(label);
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