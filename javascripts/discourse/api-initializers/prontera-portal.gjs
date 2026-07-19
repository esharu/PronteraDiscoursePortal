import { apiInitializer } from "discourse/lib/api";
import PronteraPortal from "../components/prontera-portal";

// Render the portal above the main discovery container. The component itself
// decides whether to show (homepage only + portal_enabled setting).
export default apiInitializer("1.14.0", (api) => {
  api.renderInOutlet("above-main-container", PronteraPortal);
});
