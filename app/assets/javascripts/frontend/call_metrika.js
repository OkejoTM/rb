function callMetrika(goal_name) {
    setTimeout(function() {
        if(window.yaCounter47387626) {
            window.yaCounter47387626.reachGoal(goal_name);
        }
    }, 1100);
}

export { callMetrika };