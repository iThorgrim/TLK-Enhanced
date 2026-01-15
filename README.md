<div align="center">

# 🎮 Wrath of the Lich King - Enhanced

![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow)
![Stability](https://img.shields.io/badge/stability-unstable-red)
![Version](https://img.shields.io/badge/version-2026%20Edition-blue)
![License](https://img.shields.io/badge/license-AGPL--v3-green)

*Giving WotLK's interface a little facelift with some Retail features*

[About](#-about) • [Progress](#-progress) • [License](#-license)

</div>

---

## 📝 About

A personal project to freshen up WotLK's interface. The goal isn't to revolutionize anything, but rather to clean up old code, add some nice Retail features, and document everything properly.

**What's been done so far:**
- A login screen with custom BLP animation
- Retail's NineSlice system ported to WotLK
- Mixins that work (mostly)
- LuaDoc documentation to make the code readable

**The goal:**
- Clean up FrameXML and GlueXML by removing unnecessary private server code
- Keep addon compatibility (don't touch frame names *(for FrameXML)*)
- Have cleaner, documented code

This is mainly a personal exercise in code review and improvement. Sometimes there's nothing to change, sometimes there is.

---

## 📊 Progress

### GlueXML (Login/Character Screens)
- [x] AccountLogin.lua
- [x] AccountLogin.xml
- [ ] CharacterSelect.lua
- [ ] CharacterSelect.xml
- [ ] The rest

### FrameXML (In-Game Interface)
- [ ] There is everything to do.

### Shared Systems
- [x] BLPSequence.lua - Custom animation system
- [x] NineSlice.lua - Modern layout framework
- [x] Mixin.lua - Inheritance patterns
- [x] AtlasHelper.lua - Texture management
- [ ] AHAH ! Good Question !

**Example of BLP Sequence (animated login screen)**
```lua
BLPSequence:Create("LoginScreen", "Interface\\AccountLoginUI\\ui\\frame_", 300, 30, true, {
    filesPerFrame = 2,
    layout = "horizontal"
});
```

All code is documented with LuaDoc comments for easy reading and maintenance.
- ✅ Remove unnecessary code for private server
- ✅ Provide complete open-source documentation
- 🔄 Create a reusable framework for WotLK servers
- 🔄 Enhance visual fidelity with AI upscaling

---

## 📺 Preview

Check out the animated login screen in action:
[**🎬 Watch on YouTube**](https://www.youtube.com/watch?v=ZZAJIg2MBTY)

---

## 📜 License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-v3)**.

### Important Notes

⚠️ **Disclaimer**: This project contains derivative work based on World of Warcraft's interface code. All original World of Warcraft assets, code, and intellectual property remain the property of Blizzard Entertainment. This project is intended for educational purposes and private server use only.

The AGPL-v3 license applies to:
- Original code written for this project
- Modifications and enhancements to existing code
- Custom systems and utilities

See [LICENSE](LICENSE) for full details.

---

## 🤝 Contributing

Contributions, suggestions, and feedback are welcome!

---

<div align="center">

**Made with ❤️ for the WotLK community**

*Wrath of the Lich King - Enhanced © 2026*

</div>
