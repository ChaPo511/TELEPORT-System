class ElevatorUI {
    constructor() {
        this.currentFloor = null;
        this.isMoving = false;
        this.elevatorData = null;
        this.config = null; // Config wird von FiveM gesendet

        this.elements = {
            floorLabel: document.getElementById('floorLabel'),
            floorNumber: document.getElementById('floorNumber'),
            floorName: document.getElementById('floorName'),
            arrowUp: document.getElementById('arrowUp'),
            arrowDown: document.getElementById('arrowDown'),
            progressBar: document.getElementById('progressBar'),
            progressFill: document.getElementById('progressFill'),
            floorButtonsContainer: document.getElementById('floorButtonsContainer'),
            elevatorTitle: document.getElementById('elevatorTitle'),
            elevatorLabel: document.getElementById('elevatorLabel')
        };

        // Icons
        this.iconMap = {
            house: `<svg class="floor-button-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8"/>
                <path d="M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            </svg>`,
            basement: `<svg class="floor-button-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 8.35V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8.35A2 2 0 0 1 3.26 6.5l8-3.2a2 2 0 0 1 1.48 0l8 3.2A2 2 0 0 1 22 8.35Z"/>
                <path d="M6 18h12"/>
                <path d="M6 14h12"/>
                <rect width="12" height="12" x="6" y="10"/>
            </svg>`
        };

        this.bindEvents();
    }

    bindEvents() {
        window.addEventListener('message', (event) => {
            const data = event.data;

            if (data.action === 'show') {
                this.show(data);
            } else if (data.action === 'hide') {
                this.hide();
            } else if (data.action === 'setFloor') {
                this.setCurrentFloor(data.floor);
            }
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.close();
            }
        });
    }

    show(data) {
        try {
            document.body.classList.add('show');
            document.body.style.display = 'flex';

            this.elevatorData = data.elevator;
            if (data.action === "show" && !this.elevatorData) {
                if (this.elements.elevatorTitle) this.elements.elevatorTitle.textContent = "ERR: NO DATA";
                return;
            }
            this.currentFloor = data.currentFloor;
            this.config = data.config; // Config von FiveM

            if (this.elevatorData && this.elevatorData.floors && !Array.isArray(this.elevatorData.floors)) {
                this.elevatorData.floors = Object.values(this.elevatorData.floors);
            }

            this.updateHeader();
            this.updateFloorDisplay();
            this.generateFloorButtons();
            this.setActiveButton(this.currentFloor);
        } catch (err) {
            if (this.elements.elevatorTitle) {
                this.elements.elevatorTitle.textContent = "ERR: " + err.message;
            }
        }
    }

    hide() {
        document.body.classList.remove('show');
        document.body.style.display = 'none';
        this.resetUI();
    }

    getText(key) {
        if (!this.config || !this.config.TEXTS) return key;

        const lang = this.config.LANGUAGE || 'DE';
        if (this.config.TEXTS[lang] && this.config.TEXTS[lang][key]) {
            return this.config.TEXTS[lang][key];
        }
        return this.config.TEXTS['EN'][key] || key;
    }

    updateHeader() {
        if (this.elevatorData) {
            this.elements.elevatorTitle.textContent = this.getText('ELEVATOR');
            this.elements.elevatorLabel.textContent = this.elevatorData.label;
        }
    }

    updateFloorDisplay() {
        if (!this.elevatorData || !this.currentFloor) return;

        const floor = this.elevatorData.floors.find(f => f.id === this.currentFloor);
        if (floor) {
            this.elements.floorLabel.textContent = this.getText('CURRENT_FLOOR');
            this.elements.floorNumber.textContent = floor.number;
            this.elements.floorName.textContent = floor.label;
        }
    }

    generateFloorButtons() {
        if (!this.elevatorData) return;

        this.elements.floorButtonsContainer.innerHTML = '';

        this.elevatorData.floors.forEach((floor, index) => {
            const button = document.createElement('button');
            button.className = 'floor-button';
            button.id = `btn-${floor.id}`;
            button.dataset.floor = floor.id;
            button.dataset.number = floor.number;

            button.style.animationDelay = `${index * 100}ms`;

            const icon = this.iconMap[floor.icon] || this.iconMap.house;

            button.innerHTML = `
                <div class="floor-button-left">
                    ${icon}
                    <span>${floor.label}</span>
                </div>
                <span class="floor-button-badge">${floor.number}</span>
            `;

            button.addEventListener('click', () => {
                this.selectFloor(floor.id);
            });

            this.elements.floorButtonsContainer.appendChild(button);
        });
    }

    selectFloor(floorId) {
        if (floorId === this.currentFloor || this.isMoving) return;

        this.isMoving = true;

        const currentIndex = this.elevatorData.floors.findIndex(f => f.id === this.currentFloor);
        const targetIndex = this.elevatorData.floors.findIndex(f => f.id === floorId);
        const targetFloor = this.elevatorData.floors[targetIndex];
        const direction = targetIndex < currentIndex ? 'up' : 'down';

        this.elements.floorLabel.textContent = this.getText('MOVING_TO');
        this.elements.floorNumber.textContent = targetFloor.number;
        this.elements.floorNumber.classList.add('moving');
        this.elements.floorName.textContent = targetFloor.label;

        this.elements.arrowUp.classList.toggle('active', direction === 'up');
        this.elements.arrowDown.classList.toggle('active', direction === 'down');

        this.elements.progressBar.style.display = 'block';
        this.elements.progressFill.style.animation = 'none';
        void this.elements.progressFill.offsetWidth;
        this.elements.progressFill.style.animation = 'progress 2s ease-in-out forwards';

        document.querySelectorAll('.floor-button').forEach(btn => {
            btn.disabled = true;
        });

        this.setActiveButton(floorId);

        const passcodeValue = document.getElementById('passcodeInput') ? document.getElementById('passcodeInput').value : "";

        fetch(`https://${this.getResourceName()}/selectFloor`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ floor: floorId, passcode: passcodeValue })
        })
            .then(resp => resp.json())
            .then(respData => {
                if (!respData.success) {
                    // Reset UI if teleport was denied (wrong passcode)
                    this.isMoving = false;
                    this.updateFloorDisplay();
                    this.elements.floorNumber.classList.remove('moving');
                    this.elements.arrowUp.classList.remove('active');
                    this.elements.arrowDown.classList.remove('active');
                    this.elements.progressBar.style.display = 'none';
                    document.querySelectorAll('.floor-button').forEach(btn => {
                        btn.disabled = false;
                    });
                    this.setActiveButton(this.currentFloor);
                } else {
                    // Wait for the animation to finish before updating current floor visually (Lua will hide the UI anyway)
                    setTimeout(() => {
                        this.currentFloor = floorId;
                        this.isMoving = false;
                        this.elements.floorLabel.textContent = this.getText('CURRENT_FLOOR');
                        this.elements.floorNumber.classList.remove('moving');
                        this.elements.arrowUp.classList.remove('active');
                        this.elements.arrowDown.classList.remove('active');
                        this.elements.progressBar.style.display = 'none';
                        document.querySelectorAll('.floor-button').forEach(btn => {
                            btn.disabled = false;
                        });
                    }, 2000);
                }
            })
            .catch(() => {
                this.isMoving = false;
                document.querySelectorAll('.floor-button').forEach(btn => btn.disabled = false);
            });
    }

    setActiveButton(floorId) {
        document.querySelectorAll('.floor-button').forEach(btn => {
            const btnFloor = btn.dataset.floor;
            const isActive = btnFloor === floorId;
            btn.classList.toggle('active', isActive);
        });
    }

    setCurrentFloor(floorId) {
        this.currentFloor = floorId;
        this.updateFloorDisplay();
        this.setActiveButton(floorId);
    }

    resetUI() {
        this.elements.floorLabel.textContent = this.getText('CURRENT_FLOOR');
        this.elements.floorNumber.classList.remove('moving');
        this.elements.arrowUp.classList.remove('active');
        this.elements.arrowDown.classList.remove('active');
        this.elements.progressBar.style.display = 'none';
        this.isMoving = false;

        const passcodeInput = document.getElementById('passcodeInput');
        if (passcodeInput) passcodeInput.value = '';
    }

    close() {
        fetch(`https://${this.getResourceName()}/close`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).catch(() => { });
    }

    getResourceName() {
        return GetParentResourceName ? GetParentResourceName() : 'elevator';
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.elevatorUI = new ElevatorUI();
});

// Admin Functionality
class AdminUI {
    constructor() {
        this.elevators = {};
        this.currentElevatorKey = null;
        this.panel = document.getElementById('adminPanel');
        this.bindEvents();
    }

    bindEvents() {
        document.getElementById('adminCloseBtn').addEventListener('click', () => this.close());
        document.getElementById('adminSaveBtn').addEventListener('click', () => this.saveConfig());
        document.getElementById('adminAddElevatorBtn').addEventListener('click', () => this.addElevator());
        document.getElementById('adminDeleteElevatorBtn').addEventListener('click', () => this.deleteElevator());

        // Auto update data when inputs change
        document.getElementById('editElevatorId').addEventListener('input', (e) => {
            if (this.currentElevatorKey && this.elevators[this.currentElevatorKey]) {
                this.elevators[this.currentElevatorKey].id = e.target.value;
            }
        });
        document.getElementById('editElevatorLabel').addEventListener('input', (e) => {
            if (this.currentElevatorKey && this.elevators[this.currentElevatorKey]) {
                this.elevators[this.currentElevatorKey].label = e.target.value;
            }
        });

        document.getElementById('adminAddFloorBtn').addEventListener('click', () => this.addFloor());

        // Close on ESC
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.panel.style.display === 'flex') {
                this.close();
            }
        });
    }

    open(data) {
        this.elevators = data.elevators || {};
        this.panel.style.display = 'flex';
        this.panel.style.opacity = '1';

        const normalWrapper = document.querySelector('.panel-wrapper');
        if (normalWrapper) normalWrapper.style.display = 'none';

        this.renderElevatorList();
        document.getElementById('adminEditor').style.display = 'none';
    }

    close() {
        this.panel.style.display = 'none';
        this.panel.style.opacity = '0';
        document.body.classList.remove('show');

        const normalWrapper = document.querySelector('.panel-wrapper');
        if (normalWrapper) normalWrapper.style.display = 'flex';

        fetch(`https://${window.elevatorUI.getResourceName()}/adminClose`, { method: 'POST', body: '{}' }).catch(() => { });
    }

    renderElevatorList() {
        const list = document.getElementById('adminElevatorList');
        list.innerHTML = '';

        for (const [key, el] of Object.entries(this.elevators)) {
            const item = document.createElement('div');
            item.className = 'admin-list-item' + (this.currentElevatorKey === key ? ' active' : '');
            item.textContent = el.label || el.id || key;
            item.addEventListener('click', () => this.selectElevator(key));
            list.appendChild(item);
        }
    }

    selectElevator(key) {
        this.currentElevatorKey = key;
        this.renderElevatorList();

        const editor = document.getElementById('adminEditor');
        editor.style.display = 'block';

        const el = this.elevators[key];
        document.getElementById('editElevatorTitle').textContent = `Editing: ${el.label}`;
        document.getElementById('editElevatorId').value = el.id || '';
        document.getElementById('editElevatorLabel').value = el.label || '';

        this.renderFloors();
    }

    addElevator() {
        const key = 'elevator_' + Date.now();
        this.elevators[key] = {
            id: key,
            label: 'New Elevator',
            floors: []
        };
        this.selectElevator(key);
    }

    deleteElevator() {
        if (!this.currentElevatorKey) return;
        delete this.elevators[this.currentElevatorKey];
        this.currentElevatorKey = null;
        document.getElementById('adminEditor').style.display = 'none';
        this.renderElevatorList();
    }

    addFloor() {
        if (!this.currentElevatorKey) return;
        const el = this.elevators[this.currentElevatorKey];
        if (!el.floors) el.floors = [];

        el.floors.push({
            id: 'floor_' + Date.now(),
            number: '00',
            label: 'New Floor',
            icon: 'house',
            passcode: '',
            coords: { x: 0, y: 0, z: 0, w: 0 }
        });
        this.renderFloors();
    }

    deleteFloor(index) {
        if (!this.currentElevatorKey) return;
        this.elevators[this.currentElevatorKey].floors.splice(index, 1);
        this.renderFloors();
    }

    renderFloors() {
        const container = document.getElementById('adminFloorsList');
        container.innerHTML = '';

        const el = this.elevators[this.currentElevatorKey];
        let floors = el.floors || [];
        if (!Array.isArray(floors)) floors = Object.values(floors);
        el.floors = floors; // ensure array

        floors.forEach((floor, i) => {
            const card = document.createElement('div');
            card.className = 'ox-floor-card';

            card.innerHTML = `
                <div class="ox-floor-card-header">
                    <span>FLOOR #${i + 1}</span>
                    <button class="ox-btn-icon" style="color:#ff4444; border:none; width: 24px; height: 24px; background: transparent;" onclick="window.adminUI.deleteFloor(${i})">
                        ✕
                    </button>
                </div>
                <div class="ox-form-row" style="margin-bottom: 12px;">
                    <div class="ox-form-group"><label>ID</label><input type="text" value="${floor.id || ''}" onchange="window.adminUI.updateFloor(${i}, 'id', this.value)"></div>
                    <div class="ox-form-group"><label>NUMBER</label><input type="text" value="${floor.number || ''}" onchange="window.adminUI.updateFloor(${i}, 'number', this.value)"></div>
                    <div class="ox-form-group"><label>LABEL</label><input type="text" value="${floor.label || ''}" onchange="window.adminUI.updateFloor(${i}, 'label', this.value)"></div>
                </div>
                <div class="ox-form-row">
                    <div class="ox-form-group"><label>PASSCODE</label><input type="text" value="${floor.passcode || ''}" onchange="window.adminUI.updateFloor(${i}, 'passcode', this.value)"></div>
                    <div class="ox-form-group" style="flex: 2;">
                        <label>COORDINATES</label>
                        <div style="display:flex; gap:8px;">
                            <input type="text" disabled value="${Number(floor.coords?.x || 0).toFixed(2)}, ${Number(floor.coords?.y || 0).toFixed(2)}, ${Number(floor.coords?.z || 0).toFixed(2)}" style="flex:1;" id="coords_display_${i}">
                            <button class="ox-btn-secondary" onclick="window.adminUI.captureCoords(${i})">Capture Here</button>
                        </div>
                    </div>
                </div>
            `;
            container.appendChild(card);
        });
    }

    updateFloor(index, field, value) {
        if (!this.currentElevatorKey) return;
        this.elevators[this.currentElevatorKey].floors[index][field] = value;
    }

    captureCoords(index) {
        fetch(`https://${window.elevatorUI.getResourceName()}/adminCaptureCoords`, { method: 'POST', body: '{}' })
            .then(res => res.json())
            .then(coords => {
                this.updateFloor(index, 'coords', coords);
                document.getElementById(`coords_display_${index}`).value = `${coords.x.toFixed(2)}, ${coords.y.toFixed(2)}, ${coords.z.toFixed(2)}`;
            });
    }

    saveConfig() {
        const btn = document.getElementById('adminSaveBtn');
        btn.textContent = 'Saving...';

        fetch(`https://${window.elevatorUI.getResourceName()}/adminSaveConfig`, {
            method: 'POST',
            body: JSON.stringify({ elevators: this.elevators })
        }).then(() => {
            btn.textContent = 'Saved!';
            setTimeout(() => btn.textContent = 'Save Config', 2000);
        });
    }
}

document.addEventListener('DOMContentLoaded', () => {
    window.adminUI = new AdminUI();

    // Inject listener into the main message handler
    const originalListener = window.onmessage;
    window.addEventListener('message', (event) => {
        if (event.data && event.data.action === 'openAdmin') {
            document.body.classList.add('show');
            window.adminUI.open(event.data);
        }
    });
});
