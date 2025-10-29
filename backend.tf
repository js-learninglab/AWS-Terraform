terraform {
    cloud {
        #organisation ID
        organization = "js_learninglab_hcp"

        #workspace ID
        workspaces {
            name = "js_learninglab_backend"
        }
    }
}