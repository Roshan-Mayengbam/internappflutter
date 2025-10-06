import express from 'express';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Apply authentication middleware to all student routes
router.use(authenticateToken);

// Student profile update route
const updateStudentProfile = async (req, res) => {
  try {
    const studentId = req.body.studentId || req.user?._id;
    if (!studentId) return res.status(400).json({ message: "Missing student id" });

    const allowedUpdates = [
      "email",
      "phone",
      "profile.firstName",
      "profile.lastName",
      "profile.profilePicture",
      "profile.bio",
      "profile.about",
      "profile.dateOfBirth",
      "profile.gender",
      "profile.location.city",
      "profile.location.state",
      "profile.location.country",
      "profile.location.pincode",
      "education.college",
      "education.degree",
      "education.branch",
      "education.year",
      "education.cgpa",
      "education.graduationYear",
      "user_skills",
    ];

    const updates = {};
    for (const key of allowedUpdates) {
      const parts = key.split(".");
      if (parts.length === 1) {
        if (req.body[parts[0]] !== undefined) updates[parts[0]] = req.body[parts[0]];
      } else {
        if (req.body[parts[0]] && req.body[parts[0]][parts[1]] !== undefined) {
          if (!updates[parts[0]]) updates[parts[0]] = {};
          updates[parts[0]][parts[1]] = req.body[parts[0]][parts[1]];
        }
      }
    }

    // Here you would typically update the student in your database
    // For now, we'll just return success
    console.log('Updating student profile:', studentId, updates);
    
    res.status(200).json({ 
      message: "Profile updated successfully",
      studentId: studentId,
      updates: updates
    });
  } catch (error) {
    console.error('Error updating student profile:', error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Student details route
const getStudentDetails = async (req, res) => {
  try {
    const studentId = req.body.studentId || req.user?._id;
    if (!studentId) return res.status(400).json({ message: "Missing student id" });

    // Here you would typically fetch student details from your database
    // For now, we'll return mock data
    const mockStudentData = {
      user: {
        _id: studentId,
        email: req.user.email,
        phone: "+91 72645-05924",
        profile: {
          firstName: "John",
          lastName: "Doe",
          bio: "Write about your bio",
          profilePicture: ""
        },
        education: {
          college: "Sastra College",
          degree: "Bachelor of Engineering"
        },
        user_skills: {
          "Flutter": true,
          "React": true,
          "Node.js": true
        },
        job_preference: ["Software Developer", "Mobile Developer"],
        experience: [],
        projects: []
      }
    };

    res.status(200).json(mockStudentData);
  } catch (error) {
    console.error('Error fetching student details:', error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Add skill route
const addSkill = async (req, res) => {
  try {
    const studentId = req.body.studentId || req.user?._id;
    if (!studentId) return res.status(400).json({ message: "Missing student id" });

    const { skillName } = req.body;
    if (!skillName) return res.status(400).json({ message: "Skill name is required" });

    // Here you would typically add the skill to your database
    console.log('Adding skill for student:', studentId, skillName);
    
    res.status(200).json({ 
      message: "Skill added successfully",
      skillName: skillName
    });
  } catch (error) {
    console.error('Error adding skill:', error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Routes
router.put('/profile', updateStudentProfile);
router.post('/StudentDetails', getStudentDetails);
router.post('/addSkill', addSkill);

export default router;
