"use strict";

class SmoothResizingEffect {
    constructor() {
        effect.configChanged.connect(this.loadConfig.bind(this));
        this.loadConfig();
        this.userResizing = false;

        const manageFn = this.manage.bind(this);
        effects.windowAdded.connect(manageFn);
        effects.stackingOrder.forEach(manageFn);
    }

    loadConfig() {
        const duration = effect.readConfig("Duration", 250);
        this.duration = animationTime(duration);
    }

    manage(window) {
        window.geometryChangeData = { createdTime: Date.now() };
        animate({
            window: window,
            duration: this.duration,
            curve: QEasingCurve.OutCubic,
            animations: [{
                type: Effect.Opacity,
                from: 0.0,
                to: 1.0
            }]
        });

        window.windowFrameGeometryChanged.connect(this.onWindowFrameGeometryChanged.bind(this));
        // no animation when user does it
        window.windowStartUserMovedResized.connect(() => { this.userResizing = true; });
        window.windowFinishUserMovedResized.connect(() => { this.userResizing = false; });
    }

    onWindowFrameGeometryChanged(window, oldGeometry) {
        if (!window.managed || !window.visible || !window.onCurrentDesktop || window.minimized || this.userResizing) {
            return;
        }

        const windowAge = Date.now() - window.geometryChangeData.createdTime;
        if (windowAge < 25) return;

        const newGeometry = window.geometry;

        const xDelta = newGeometry.x - oldGeometry.x;
        const yDelta = newGeometry.y - oldGeometry.y;
        const widthDelta = newGeometry.width - oldGeometry.width;
        const heightDelta = newGeometry.height - oldGeometry.height;
        const widthRatio = oldGeometry.width / newGeometry.width;
        const heightRatio = oldGeometry.height / newGeometry.height;

        animate({
            window: window,
            duration: this.duration,
            curve: QEasingCurve.OutExpo,
            animations: [
                {
                    type: Effect.Translation,
                    from: { value1: -xDelta - widthDelta / 2, value2: -yDelta - heightDelta / 2 },
                    to: { value1: 0, value2: 0 }
                },
                {
                    type: Effect.Scale,
                    from: { value1: widthRatio, value2: heightRatio },
                    to: { value1: 1, value2: 1 }
                }
            ]
        });
    }
}

new SmoothResizingEffect();
